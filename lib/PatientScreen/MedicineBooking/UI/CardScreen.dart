import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Medicine_Color/Button.dart';
import '../Medicine_Color/Color.dart';
import '../Medicine_Databases.dart';
import '../Model/Card_Model.dart';
import 'ConfirmPayment_Screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final DatabaseHelper1 _databaseHelper = DatabaseHelper1();
  final NumberFormat _currencyFormatter = NumberFormat.currency(symbol: '₹');
  late Future<List<CartItem>> _cartItemsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _cartItemsFuture = _databaseHelper.getCartItems().then(
            (items) => items.map((item) => CartItem.fromMap(item)).toList(),
      );
    });
  }

  Future<void> _removeItemFromCart(int id) async {
    setState(() => _isLoading = true);
    try {
      await _databaseHelper.removeFromCart(id);
      await _loadCartItems();
      _showMessage('Item removed from cart', isError: false);
    } catch (e) {
      _showMessage('Failed to remove item', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateItemQuantity(int id, int newQuantity) async {
    if (newQuantity > 0) {
      setState(() => _isLoading = true);
      await _databaseHelper.updateCartItemQuantity(id, newQuantity);
      await _loadCartItems();
      setState(() => _isLoading = false);
    } else {
      await _removeItemFromCart(id);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  List<String> _formatCartContents(List<CartItem> items) {
    return items.map((item) => '${item.medicineName} (Qty: ${item.quantity})').toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadCartItems,
              tooltip: 'Refresh cart',
            ),
          ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<CartItem>>(
            future: _cartItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Unable to load cart items',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                );
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add some medicines to get started',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              final totalAmount = items.fold(
                0.0,
                    (sum, item) => sum + item.totalPrice,
              );
              final cartContents = _formatCartContents(items);

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) => CartItemCard(
                        item: items[index],
                        currencyFormatter: _currencyFormatter,
                        onRemove: _removeItemFromCart,
                        onQuantityChanged: _updateItemQuantity,
                      ),
                    ),
                  ),
                  CartSummary(
                    total: totalAmount,
                    currencyFormatter: _currencyFormatter,
                    cartContents: cartContents,
                  ),
                ],
              );
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final NumberFormat currencyFormatter;
  final Function(int) onRemove;
  final Function(int, int) onQuantityChanged;

  const CartItemCard({
    required this.item,
    required this.currencyFormatter,
    required this.onRemove,
    required this.onQuantityChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(item.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Are you sure you want to remove this item from your cart?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('REMOVE'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onRemove(item.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_services,
                  size: 30,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.medicineName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormatter.format(item.price)} each',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    currencyFormatter.format(item.totalPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  QuantitySelector(
                    quantity: item.quantity,
                    onIncrement: () => onQuantityChanged(item.id, item.quantity + 1),
                    onDecrement: () => onQuantityChanged(item.id, item.quantity - 1),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onRemove(item.id),
                tooltip: 'Remove item',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onDecrement,
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrement,
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final double total;
  final NumberFormat currencyFormatter;
  final List<String> cartContents;

  const CartSummary({
    required this.total,
    required this.currencyFormatter,
    required this.cartContents,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cartContents.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...cartContents.map(
                      (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Text('• '),
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                currencyFormatter.format(total),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmOrderPage(
                    selectedItems: cartContents,
                    totalAmount: total,
                  ),
                ),
              );
            },
            child: const Text(
              'PROCEED TO CHECKOUT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}