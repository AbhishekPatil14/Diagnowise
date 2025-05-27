import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotPatientWidget extends StatefulWidget {
  const ChatbotPatientWidget({super.key});

  @override
  State<ChatbotPatientWidget> createState() => _ChatbotPatientWidgetState();
}

class _ChatbotPatientWidgetState extends State<ChatbotPatientWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> messages = [];
  bool isLoading = false;

  // Expanded medical knowledge base
  final Map<String, String> medicalResponses = {
    // Common symptoms
    'fever': 'If you have a fever:\n• Rest and drink plenty of fluids\n• Take acetaminophen/paracetamol or ibuprofen to reduce fever\n• Use a light blanket if you have chills\n• Seek medical attention if fever is above 103°F (39.4°C), lasts more than 3 days, or is accompanied by severe headache, stiff neck, confusion, or difficulty breathing.',
    'cold': 'For common cold symptoms:\n• Rest and stay hydrated\n• Use saline nasal drops or sprays\n• Try steam inhalation or a humidifier\n• Take over-the-counter cold medications for symptom relief\n• Consider zinc lozenges or vitamin C within 24 hours of symptoms\n• See a doctor if symptoms worsen after a week or if you have difficulty breathing.',
    'cough': 'For cough management:\n• Stay well hydrated\n• Use honey (if over 1 year old) to soothe throat\n• Try cough drops or lozenges\n• Use a humidifier or take steamy showers\n• For dry cough: consider cough suppressants\n• For productive cough: expectorants may help\n• See a doctor if coughing blood, having difficulty breathing, or cough persists over 2 weeks.',
    'headache': 'For headache relief:\n• Rest in a quiet, dark room\n• Apply cold or warm compress to your head\n• Stay hydrated\n• Try over-the-counter pain relievers like acetaminophen or ibuprofen\n• Practice relaxation techniques\n• Seek immediate medical attention if headache is sudden and severe, follows a head injury, or comes with fever, stiff neck, confusion, seizures, double vision, weakness, numbness, or difficulty speaking.',
    'sore throat': 'For sore throat relief:\n• Gargle with warm salt water (1/2 tsp salt in 8 oz water)\n• Drink warm liquids like tea with honey\n• Use throat lozenges or sprays\n• Take pain relievers like acetaminophen or ibuprofen\n• Use a humidifier\n• See a doctor if sore throat is severe, lasts longer than a week, or is accompanied by difficulty swallowing/breathing or rash.',
    'nausea': 'For nausea management:\n• Eat small, frequent meals and bland foods\n• Avoid strong odors, greasy or spicy foods\n• Drink clear liquids slowly\n• Try ginger tea or candies\n• Rest and avoid physical activity after eating\n• See a doctor if nausea persists over 2 days, or is accompanied by severe pain, dehydration or confusion.',
    'diarrhea': 'For diarrhea management:\n• Stay hydrated with water, clear broths, or rehydration solutions\n• Avoid dairy, caffeine, and high-fiber foods temporarily\n• Try the BRAT diet (bananas, rice, applesauce, toast)\n• Avoid anti-diarrheal medications if you have fever or blood in stool\n• Seek medical attention if diarrhea lasts more than 2 days, is accompanied by severe pain, fever over 102°F (39°C), or signs of dehydration.',
    'stomach pain': 'For stomach pain:\n• Try to identify and avoid trigger foods\n• Eat smaller meals slowly\n• Avoid NSAIDs if possible\n• Apply a heating pad to your stomach\n• Try over-the-counter antacids for indigestion\n• Seek immediate medical attention if pain is severe or persistent, especially if accompanied by fever, vomiting, inability to keep food down, bloody stool, or yellowing skin.',
    'rash': 'For skin rashes:\n• Avoid scratching and irritants\n• Use mild, fragrance-free soap\n• Apply cold compresses for itching\n• Try calamine lotion or hydrocortisone cream\n• Take an antihistamine for allergic reactions\n• See a doctor if the rash is widespread, painful, infected, accompanied by fever, or doesn\'t improve within a few days.',
    'back pain': 'For back pain relief:\n• Apply ice for the first 48-72 hours, then switch to heat\n• Take over-the-counter pain relievers\n• Stay active but avoid activities that worsen pain\n• Try gentle stretching exercises\n• Maintain good posture\n• Seek medical attention if pain is severe, spreads down your legs below the knee, causes weakness/numbness in legs, or is accompanied by bowel/bladder problems.',

    // Common conditions
    'high blood pressure': 'For high blood pressure management:\n• Monitor your blood pressure regularly\n• Reduce sodium intake (less than 2,300mg daily)\n• Eat a diet rich in fruits, vegetables, and whole grains\n• Exercise regularly (aim for 150 minutes per week)\n• Limit alcohol consumption\n• Quit smoking\n• Manage stress\n• Take prescribed medications as directed\n• See your doctor regularly for check-ups.',
    'diabetes': 'For diabetes management:\n• Monitor blood sugar levels as recommended\n• Follow a balanced diet with consistent carbohydrate intake\n• Exercise regularly\n• Take medications as prescribed\n• Check feet daily for cuts or sores\n• Manage stress levels\n• Get regular eye exams\n• See your healthcare provider regularly\n• Seek immediate care for very high or low blood sugar levels.',
    'anxiety': 'For anxiety management:\n• Practice deep breathing and relaxation techniques\n• Exercise regularly\n• Limit caffeine and alcohol\n• Maintain a regular sleep schedule\n• Try meditation or mindfulness practices\n• Consider cognitive behavioral therapy\n• Speak with a healthcare provider about medication options if needed\n• Join a support group',
    'depression': 'For depression management:\n• Establish a daily routine\n• Set realistic goals\n• Exercise regularly\n• Eat healthy, regular meals\n• Get enough sleep\n• Avoid alcohol and recreational drugs\n• Challenge negative thoughts\n• Connect with supportive people\n• Consider therapy or counseling\n• Consult a healthcare provider about treatment options including medication',
    'asthma': 'For asthma management:\n• Know your triggers and avoid them\n• Take prescribed medications as directed\n• Use your rescue inhaler when needed\n• Follow your asthma action plan\n• Get vaccinated against flu and pneumonia\n• Use a peak flow meter to monitor symptoms\n• Seek immediate medical help if you have severe shortness of breath, rapid breathing, difficulty speaking, or blue lips or fingernails.',
    'allergy': 'For allergy management:\n• Identify and avoid allergens when possible\n• Keep windows closed during high pollen seasons\n• Use air purifiers indoors\n• Try over-the-counter antihistamines, nasal sprays, or eye drops\n• Consider immunotherapy (allergy shots) for severe allergies\n• Wear medical alert identification if you have severe allergic reactions\n• Seek emergency care for signs of anaphylaxis (difficulty breathing, throat tightness, severe hives, dizziness).',

    // Medications and treatments
    'painkillers': 'Common over-the-counter painkillers include:\n• Acetaminophen/paracetamol (Tylenol): Good for pain and fever, gentle on stomach\n• Ibuprofen (Advil, Motrin): Reduces inflammation, pain and fever\n• Aspirin: Pain relief and anti-inflammatory\n• Naproxen (Aleve): Longer-lasting anti-inflammatory\n\nAlways follow package directions, don\'t exceed recommended doses, and consult a healthcare provider if you have chronic conditions or take other medications.',
    'antibiotics': 'Important facts about antibiotics:\n• Only effective against bacterial infections, not viral infections like colds or flu\n• Always complete the full prescribed course, even if you feel better\n• Take as directed with regard to timing and food\n• Some may decrease effectiveness of birth control pills\n• Common side effects include diarrhea, nausea, and yeast infections\n• Never take antibiotics prescribed for someone else\n• Antibiotic resistance is a serious concern when antibiotics are misused',
    'vaccination': 'Vaccinations are one of the most effective ways to prevent infectious diseases. They work by helping your immune system recognize and fight specific pathogens. Regular vaccination schedules are recommended for children and adults, including boosters for certain vaccines. Common vaccines include those for flu, tetanus, measles, mumps, rubella, pneumonia, shingles, and HPV. Consult your healthcare provider about which vaccines are recommended for you based on your age, health condition, and vaccination history.',

    // Lifestyle and prevention
    'diet': 'Recommendations for a healthy diet:\n• Eat plenty of fruits, vegetables, and whole grains\n• Choose lean proteins like fish, poultry, beans, and nuts\n• Limit saturated fats, trans fats, sodium, and added sugars\n• Control portion sizes\n• Stay hydrated with water\n• Minimize processed foods\n• Consider your specific health needs (e.g., diabetes, heart disease)\n\nFor personalized dietary advice, consult a registered dietitian or nutritionist.',
    'exercise': 'Exercise recommendations:\n• Aim for at least 150 minutes of moderate aerobic activity or 75 minutes of vigorous activity weekly\n• Include muscle-strengthening activities at least twice a week\n• Start slowly if you\'ve been inactive\n• Choose activities you enjoy\n• Break up exercise into smaller sessions if needed\n• Include flexibility exercises\n• Stay hydrated and listen to your body\n• Consult a healthcare provider before starting a new exercise program if you have chronic conditions.',
    'sleep': 'For better sleep:\n• Maintain a consistent sleep schedule\n• Create a relaxing bedtime routine\n• Make your bedroom cool, dark, and quiet\n• Limit screen time before bed\n• Avoid caffeine, alcohol, and large meals before bedtime\n• Exercise regularly, but not close to bedtime\n• Manage stress through relaxation techniques\n• Limit daytime naps\n• Consult a healthcare provider if you have persistent sleep problems.',
    'stress': 'Stress management techniques:\n• Practice deep breathing exercises\n• Try progressive muscle relaxation\n• Engage in regular physical activity\n• Maintain social connections\n• Practice mindfulness meditation\n• Get enough sleep\n• Set realistic goals and priorities\n• Take breaks from news and social media\n• Seek professional help if stress is overwhelming or persistent.',
    'weight loss': 'Healthy weight management tips:\n• Focus on sustainable lifestyle changes rather than quick fixes\n• Aim for a balanced diet with appropriate portions\n• Increase physical activity gradually\n• Set realistic goals (0.5-2 lbs per week is healthy)\n• Track your food intake and exercise\n• Stay hydrated\n• Get adequate sleep\n• Manage stress\n• Consider working with healthcare providers or registered dietitians\n• Remember that healthy weight varies by individual',

    // General queries
    'hello': 'Hello! I\'m your healthcare assistant. How can I help with your health questions today?',
    'hi': 'Hi there! I can provide basic health information and advice. What health topic can I help you with?',
    'help': 'I can provide information about common symptoms, conditions, medications, and healthy lifestyle practices. Just ask me a specific health question, and I\'ll do my best to assist you. Remember that I\'m not a replacement for professional medical advice.',
    'thank': 'You\'re welcome! If you have any other health questions, feel free to ask. Remember to consult healthcare professionals for personalized medical advice.',
    'bye': 'Take care of your health! Remember to consult with healthcare professionals for personalized medical advice. Feel free to return if you have more health questions.',


    // Additional symptoms
    'vomiting': 'For vomiting:\n• Sip clear fluids slowly (water, ginger ale, electrolyte solutions)\n• Avoid solid foods until vomiting subsides\n• When tolerable, start with bland foods like crackers or toast\n• Avoid dairy, spicy, or greasy food\n• Rest and avoid strong smells\n• Seek medical care if vomiting persists over 24 hours, has blood, or is accompanied by severe pain or dehydration.',
    'fatigue': 'For managing fatigue:\n• Ensure adequate sleep and rest\n• Eat a balanced diet with regular meals\n• Stay hydrated\n• Get regular physical activity\n• Limit caffeine and alcohol\n• Manage stress and mental health\n• See a doctor if fatigue is persistent or affecting daily life, especially with weight loss or other symptoms.',
    'dizziness': 'For dizziness:\n• Sit or lie down immediately to prevent falls\n• Move slowly when changing positions\n• Drink water and stay hydrated\n• Avoid caffeine and alcohol\n• Eat regular meals to maintain blood sugar\n• See a doctor if dizziness is severe, recurrent, or accompanied by fainting, chest pain, or vision changes.',

    // Additional conditions
    'thyroid': 'For thyroid health:\n• Take thyroid medications as prescribed\n• Regularly monitor your thyroid hormone levels\n• Eat a balanced diet rich in iodine (if recommended by doctor)\n• Avoid high-soy and raw cruciferous vegetables if you have hypothyroidism\n• Report symptoms like fatigue, weight change, or mood swings to your doctor\n• Have regular check-ups with an endocrinologist.',
    'pcos': 'For managing PCOS (Polycystic Ovary Syndrome):\n• Maintain a healthy weight\n• Exercise regularly\n• Follow a low-sugar, low-carb diet\n• Consider hormonal birth control to regulate periods\n• Manage stress\n• Get regular checkups and screening for related risks (diabetes, cholesterol, etc.)\n• Consult with a gynecologist or endocrinologist for a personalized treatment plan.',
    'heart disease': 'For heart disease management:\n• Eat a heart-healthy diet (low in saturated fat, salt, and cholesterol)\n• Exercise regularly under medical supervision\n• Take medications as prescribed\n• Quit smoking and limit alcohol\n• Monitor blood pressure and cholesterol\n• Manage stress through relaxation techniques\n• Keep regular appointments with your cardiologist.',

    // Additional medications and treatments
    'insulin': 'Insulin is used for managing diabetes:\n• Take insulin exactly as prescribed\n• Monitor blood sugar before and after doses\n• Store insulin properly (typically in the fridge)\n• Rotate injection sites\n• Watch for signs of low blood sugar (shakiness, sweating, confusion)\n• Always carry snacks or glucose tablets\n• Consult your doctor for dose adjustments.',
    'inhaler': 'Inhalers are used for asthma and other lung conditions:\n• Use as directed (daily control vs. emergency relief)\n• Shake well before use if required\n• Rinse mouth after steroid inhalers\n• Track usage and symptoms\n• Carry rescue inhalers during travel or activities\n• Replace inhalers before they expire\n• Seek emergency help for worsening breathing.',
    'multivitamins': 'Multivitamins:\n• Can help fill dietary gaps, but not replace a balanced diet\n• Choose vitamins suited to your age and gender\n• Take with food for better absorption\n• Avoid exceeding recommended daily doses\n• Consult a doctor before combining with other supplements\n• Store in a cool, dry place away from children.',

    // Additional lifestyle tips
    'hydration': 'Hydration tips:\n• Aim for 8-10 glasses of water daily\n• Increase intake in hot weather or during exercise\n• Drink water before meals to aid digestion\n• Limit sugary drinks and caffeine\n• Watch for signs of dehydration: dark urine, dry mouth, fatigue\n• Add lemon or fruit slices for flavor if needed.',
    'sun protection': 'To protect your skin from sun damage:\n• Use broad-spectrum sunscreen SPF 30 or higher\n• Reapply every 2 hours or after swimming/sweating\n• Wear sunglasses, hats, and protective clothing\n• Avoid peak sun hours (10 am to 4 pm)\n• Seek shade when possible\n• Protect children and infants from direct sun exposure.',
    'mental health': 'Caring for your mental health:\n• Talk to someone you trust about your feelings\n• Practice self-care routines\n• Limit screen and social media time\n• Stay physically active\n• Seek therapy or counseling when needed\n• Don’t hesitate to reach out for help – mental health matters!',

    // More general queries
    'what can you do': 'I can answer basic health-related questions about symptoms, treatments, medications, and healthy lifestyle practices. Just type a health concern, and I’ll try to help!',
    'symptom checker': 'Tell me your symptoms (e.g., "fever", "headache") and I’ll give you general tips and when to seek medical attention. I don’t replace a real doctor, but I can offer helpful info!',

    'acne': 'For acne treatment:\n• Wash your face twice daily with a gentle cleanser\n• Avoid picking or squeezing pimples\n• Use over-the-counter creams with benzoyl peroxide or salicylic acid\n• Keep hair clean and away from your face\n• Avoid heavy makeup or oily skincare products\n• See a dermatologist if acne is severe or leaves scars.',

    'menstrual cramps': 'For menstrual cramp relief:\n• Use a heating pad on your abdomen\n• Take NSAIDs like ibuprofen\n• Try gentle exercise or yoga\n• Stay hydrated and avoid caffeine\n• Consider hormonal birth control if cramps are persistent\n• Consult a gynecologist for chronic or severe pain.',

    'eye strain': 'For eye strain:\n• Follow the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds\n• Use proper lighting and screen brightness\n• Adjust screen distance and angle\n• Use artificial tears if eyes are dry\n• See an eye doctor for vision correction or persistent discomfort.',

    'constipation': 'For constipation relief:\n• Increase fiber intake (fruits, vegetables, whole grains)\n• Drink plenty of water\n• Get regular exercise\n• Establish a regular bathroom routine\n• Avoid overuse of laxatives\n• See a doctor if constipation lasts more than 3 days or is accompanied by pain or bleeding.',

    'bloating': 'To reduce bloating:\n• Eat slowly and chew food thoroughly\n• Avoid carbonated drinks and gas-producing foods\n• Try peppermint tea or ginger\n• Stay active after eating\n• See a doctor for persistent or painful bloating.',

    'migraine': 'For migraine management:\n• Rest in a quiet, dark room\n• Apply a cold compress to the head or neck\n• Take migraine-specific medication early\n• Avoid known triggers like certain foods or bright lights\n• Keep a migraine diary\n• Seek medical help for frequent or severe migraines.',

    'bruising': 'For bruising:\n• Apply a cold compress for the first 24-48 hours\n• Elevate the area if possible\n• Avoid re-injury\n• Use pain relievers like acetaminophen (not aspirin or ibuprofen initially)\n• Seek medical attention if bruises appear without injury or are very large and painful.',

    'nosebleed': 'For a nosebleed:\n• Sit upright and lean forward\n• Pinch your nostrils together for 10–15 minutes\n• Apply a cold compress to the nose bridge\n• Avoid blowing your nose afterward\n• See a doctor if bleeding is frequent, heavy, or lasts over 20 minutes.',

    'itching': 'For itching relief:\n• Use a cold compress or anti-itch cream (hydrocortisone)\n• Take an antihistamine for allergies\n• Avoid hot showers and scented soaps\n• Keep skin moisturized\n• See a doctor if itching is persistent or spreads.',

    'ear pain': 'For ear pain:\n• Apply a warm compress\n• Take over-the-counter pain relievers\n• Avoid inserting anything into the ear\n• See a doctor if pain lasts over 2 days, is severe, or comes with hearing loss or discharge.',

    'acid reflux': 'For acid reflux:\n• Avoid spicy, fatty, and acidic foods\n• Eat smaller meals and don’t lie down right after eating\n• Elevate the head of your bed\n• Avoid caffeine and alcohol\n• Try antacids or H2 blockers\n• See a doctor if symptoms are frequent or severe.',

    'dandruff': 'For dandruff treatment:\n• Use anti-dandruff shampoos with zinc pyrithione, ketoconazole, or selenium sulfide\n• Avoid hair products that irritate the scalp\n• Keep your scalp clean and moisturized\n• Manage stress\n• See a dermatologist if it doesn’t improve with over-the-counter products.',

    'diarrhea': 'For diarrhea relief:\n• Stay hydrated with water, clear broth, or oral rehydration solutions\n• Eat bland foods like bananas, rice, applesauce, and toast (BRAT diet)\n• Avoid dairy, caffeine, and fatty foods\n• Rest\n• See a doctor if diarrhea lasts more than 2 days or includes blood or high fever.',

    'back pain': 'For back pain relief:\n• Apply ice or heat to the affected area\n• Maintain good posture\n• Avoid heavy lifting or twisting\n• Stretch gently and stay active\n• Use over-the-counter pain relief if needed\n• Seek medical help if pain persists or radiates to the legs.',

    'indigestion': 'For indigestion:\n• Eat slowly and chew thoroughly\n• Avoid overeating, spicy or greasy foods\n• Don’t lie down immediately after meals\n• Try antacids for relief\n• Reduce stress\n• See a doctor if indigestion is frequent or painful.',

    'cough': 'For cough relief:\n• Stay hydrated and drink warm fluids like tea with honey\n• Use a humidifier to moisten the air\n• Try cough drops or syrup\n• Avoid irritants like smoke or dust\n• Seek medical help if the cough lasts over 3 weeks or includes blood or severe chest pain.',

    'joint pain': 'For joint pain:\n• Rest the affected joint and avoid overuse\n• Apply ice or heat\n• Take anti-inflammatory medications like ibuprofen\n• Exercise regularly to maintain flexibility\n• Consider physical therapy\n• Consult a doctor if pain is persistent or worsens.',

    'nausea': 'For nausea relief:\n• Sip clear fluids or ginger tea\n• Eat bland, light foods like crackers or toast\n• Avoid strong odors and greasy foods\n• Rest and avoid sudden movements\n• Try over-the-counter remedies like dimenhydrinate\n• See a doctor if nausea is severe or lasts more than a day.',

    'skin rash': 'For skin rashes:\n• Apply a cool compress or anti-itch cream\n• Avoid scratching the area\n• Use gentle, fragrance-free cleansers\n• Identify and avoid potential allergens\n• See a dermatologist if the rash spreads, is painful, or lasts several days.',

    'throat pain': 'For sore throat relief:\n• Gargle with warm salt water\n• Drink warm liquids and stay hydrated\n• Suck on lozenges or use throat sprays\n• Avoid irritants like smoke\n• Take pain relievers like acetaminophen\n• Seek medical attention if symptoms last more than 3 days or include high fever.',

    'high blood pressure': 'For managing high blood pressure:\n• Reduce salt intake and eat a heart-healthy diet\n• Exercise regularly (at least 30 minutes most days)\n• Maintain a healthy weight\n• Limit alcohol and avoid tobacco\n• Manage stress through relaxation techniques\n• Take prescribed medications consistently\n• Monitor your blood pressure regularly\n• Consult your doctor for regular checkups and adjustments.',


  };

  // Additional specialized medical responses
  final Map<String, Map<String, String>> specializedResponses = {
    'heart': {
      'attack': 'Heart attack warning signs include chest pain/pressure, pain radiating to arm/jaw/back, shortness of breath, cold sweat, nausea, and lightheadedness. If you suspect a heart attack, call emergency services (911) immediately. While waiting, chew an aspirin if not allergic and sit or lie down.',
      'failure': 'Heart failure symptoms include shortness of breath (especially when lying down), fatigue, swelling in legs/ankles, rapid heartbeat, reduced ability to exercise, persistent cough, sudden weight gain, and difficulty concentrating. If you experience these symptoms, especially if sudden or severe, seek medical attention.',
      'palpitations': 'Heart palpitations feel like your heart is racing, fluttering, or skipping beats. While often harmless, they can sometimes indicate serious conditions. Stay hydrated, avoid stimulants like caffeine, practice relaxation techniques, and track when they occur. See a doctor if palpitations are frequent, worsen, or come with chest pain, severe shortness of breath, or fainting.',
      'disease': 'Heart disease prevention includes: maintaining healthy blood pressure and cholesterol levels, eating a heart-healthy diet, exercising regularly, maintaining healthy weight, not smoking, limiting alcohol, managing stress, and getting regular check-ups. If you have risk factors, work closely with your healthcare provider.',
    },
    'covid': {
      'symptoms': 'Common COVID-19 symptoms include fever, cough, fatigue, loss of taste or smell, sore throat, headache, body aches, shortness of breath, congestion, nausea, and diarrhea. Symptoms can appear 2-14 days after exposure. If you experience severe symptoms (trouble breathing, persistent chest pain, confusion, inability to stay awake, bluish lips), seek emergency medical care immediately.',
      'test': 'COVID-19 testing options include PCR tests (most accurate, results in 1-3 days), rapid antigen tests (results in 15-30 minutes but less sensitive), and at-home tests. If you have symptoms or were exposed, you should get tested. Many pharmacies, clinics, and community centers offer testing. Check local health department websites for testing locations.',
      'vaccine': 'COVID-19 vaccines are safe and effective at preventing severe illness, hospitalization, and death. Common side effects include pain at injection site, fatigue, headache, muscle pain, chills, fever, and nausea, typically lasting 1-2 days. Stay updated with recommended boosters. Consult your healthcare provider about which vaccine is right for you, especially if you have specific health conditions.',
      'long': 'Long COVID refers to symptoms that persist weeks or months after the initial COVID-19 infection. Common symptoms include fatigue, shortness of breath, cognitive issues ("brain fog"), headaches, loss of smell or taste, joint or muscle pain, sleep problems, heart palpitations, and mood changes. If you\'re experiencing these symptoms, talk to your healthcare provider about management strategies and support resources.',
    },
    'pregnancy': {
      'symptoms': 'Early pregnancy signs include missed period, nausea/vomiting, breast tenderness, fatigue, increased urination, and mild cramping. Take a home pregnancy test or see a healthcare provider to confirm pregnancy. If pregnant, schedule prenatal care promptly.',
      'diet': 'During pregnancy, eat a variety of nutrient-rich foods including fruits, vegetables, whole grains, lean proteins, and dairy. Take prenatal vitamins with folic acid. Avoid alcohol, limit caffeine, avoid raw/undercooked meats, unpasteurized dairy, raw eggs, high-mercury fish, and unwashed produce. Stay well hydrated and consult your healthcare provider about specific dietary needs.',
      'exercise': 'Safe pregnancy exercises include walking, swimming, stationary cycling, modified yoga, and low-impact aerobics. Aim for 150 minutes of moderate activity weekly. Avoid contact sports, activities with falling risk, hot yoga, scuba diving, and exercising in high heat. Stop exercising and contact your healthcare provider if you experience pain, dizziness, shortness of breath, vaginal bleeding, or contractions.',
      'danger': 'Pregnancy warning signs requiring immediate medical attention include severe abdominal pain, heavy vaginal bleeding, severe headache, visual changes, sudden swelling of face/hands, contractions before 37 weeks, decreased fetal movement, fever over 100.4°F (38°C), and thoughts of harming yourself or your baby.',
    },
    'child': {
      'fever': 'For children with fever: Use acetaminophen or ibuprofen (follow age-appropriate dosing), dress in light clothing, keep room comfortable, offer plenty of fluids. Contact doctor immediately if: under 3 months with any fever, 3-36 months with fever over 102°F (38.9°C), fever with rash, breathing difficulty, unusual drowsiness, persistent vomiting, or fever lasting more than 2-3 days.',
      'vaccination': 'Childhood vaccinations follow a recommended schedule starting at birth through age 18. These protect against serious diseases like measles, whooping cough, polio, and more. Vaccines are thoroughly tested for safety. Common side effects include soreness at injection site, mild fever, and fussiness. Keep records of your child\'s vaccinations and stay on schedule with recommended boosters.',
      'growth': 'Child growth varies widely but follows patterns. Your pediatrician tracks height, weight, and head circumference on growth charts. Children need balanced nutrition, physical activity, and adequate sleep for proper development. If concerned about your child\'s growth, discuss with your pediatrician rather than comparing to other children.',
      'development': 'Child development includes physical, cognitive, social, and emotional milestones that occur in a general sequence but at variable rates. Talk to your pediatrician if you notice delays in speech, movement, social skills, or learning. Early intervention can make a significant difference for developmental concerns.',
    }
  };

  // Check for specific medical topics in the query
  String getSpecializedResponse(String query) {
    query = query.toLowerCase();

    for (var category in specializedResponses.keys) {
      if (query.contains(category)) {
        for (var keyword in specializedResponses[category]!.keys) {
          if (query.contains(keyword)) {
            return specializedResponses[category]![keyword]!;
          }
        }
      }
    }

    return '';
  }

  String getMedicalResponse(String query) {
    // First check specialized responses
    String specializedAnswer = getSpecializedResponse(query);
    if (specializedAnswer.isNotEmpty) {
      return specializedAnswer;
    }

    // Check main medical responses
    final lowerQuery = query.toLowerCase();
    for (final keyword in medicalResponses.keys) {
      if (lowerQuery.contains(keyword)) {
        return medicalResponses[keyword]!;
      }
    }
    return getFallbackResponse();
  }

  String getFallbackResponse() {
    return 'I don\'t have specific information about that health topic. For accurate medical advice, please consult a healthcare professional or contact your doctor. You can also try asking me about common symptoms like fever, cough, or headache, or about general health topics like diet, exercise, or sleep.';
  }

  void sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'content': message});
    });

    // Scroll to bottom
    _scrollToBottom();

    // Get response from local database
    String reply = getMedicalResponse(message);

    setState(() {
      messages.add({'role': 'assistant', 'content': reply});
    });

    // Scroll to show the new message
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildMessage(Map<String, String> msg) {
    bool isUser = msg['role'] == 'user';
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : const Color(0xFFE8F5FE),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          msg['content'] ?? '',
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Healthcare Assistant',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Ask me about your symptoms or health concerns. Please remember this is not a substitute for professional medical advice.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 70,
                    color: Colors.teal.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Start a conversation',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Try asking about symptoms, medications, or general health topics',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Processing your question...",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about your health...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => _controller.clear(),
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) {
                      if (text.isNotEmpty && !isLoading) {
                        sendMessage(text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 22),
                    onPressed: isLoading
                        ? null
                        : () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        sendMessage(text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}