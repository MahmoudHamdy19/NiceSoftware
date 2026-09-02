import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lvekpxngupfivvfaobxa.supabase.co',
    'sb_publishable_2b1Em4p587-JeQA_7A_8vw_f0UYZk_J',
  );

  final projects = [
    {
      'title': 'Qailat - قيلات',
      'category': 'Apple Store',
      'image_url': '',
      'link_url': 'Application published on Apple Store',
    },
    {
      'title': 'Sejel - سجل',
      'category': 'Apple Store',
      'image_url': '',
      'link_url': 'Application published on Apple Store',
    },
    {
      'title': 'Maseef',
      'category': 'Flutter, Firebase, Rest API, Dart',
      'image_url': '',
      'link_url': 'An event management and ticketing app to help users book and attend events easily.\nRole: Lead developer; developed user registration, payment processing, and ticket scanning features.',
    },
    {
      'title': 'unibus',
      'category': 'Flutter, Google Maps API, Firebase, Dart',
      'image_url': '',
      'link_url': 'A bus tracking and booking app designed to offer real-time tracking of buses and seat reservations.\nRole: Built real-time GPS tracking, booking system, and notification system.',
    },
    {
      'title': 'HealthForecast',
      'category': 'Flutter, Node.js, Firebase, Python',
      'image_url': '',
      'link_url': 'A health monitoring app that provides personalized health insights based on user data and trends.\nRole: Designed and implemented the user dashboard and integrated machine learning models.',
    },
    {
      'title': 'linkbus',
      'category': 'Flutter, Firebase, Google Map, Dart',
      'image_url': '',
      'link_url': 'An app that connects users with nearby buses and helps plan the best routes for travel.\nRole: Developed the route-planning algorithm and integrated map features.',
    },
    {
      'title': 'Let\'s Have Fun',
      'category': 'Flutter, Firebase, Dart, Speech Recognition API',
      'image_url': '',
      'link_url': 'An interactive app designed for children with autism, featuring voice-activated questions and interactive images to aid learning and engagement.',
    },
    {
      'title': 'cece',
      'category': 'Flutter, Firebase, Dart',
      'image_url': '',
      'link_url': 'A web platform built with WebFlutter that allows users to create mobile applications for conferences.',
    },
    {
      'title': 'Talk to me',
      'category': 'Flutter, Google Gemini API, Firebase, Dart',
      'image_url': '',
      'link_url': 'AI-powered chatbot app using Google Gemini to assist users in natural language conversations.',
    },
    {
      'title': 'Dewan Albena Company',
      'category': 'Flutter Web, Firebase, Dart',
      'image_url': '',
      'link_url': 'https://dewanalbena.com/\nA Flutter-based website designed to showcase the services of a Saudi construction company.',
    },
    {
      'title': 'Mechanic',
      'category': 'Flutter, Firebase, Dart, Payment Gateway API',
      'image_url': '',
      'link_url': 'A mobile application that helps users find and book mechanic workshops, allowing them to reserve services, make payments, and track the status of their service requests.',
    },
    {
      'title': 'Rababa',
      'category': 'Flutter',
      'image_url': '',
      'link_url': 'Project developed in 2023.',
    }
  ];

  print('Inserting projects into Supabase...');
  try {
    for (var project in projects) {
      await supabase.from('projects_content').insert(project);
      final t = project['title'];
      print('Inserted: $t');
    }
    print('All projects inserted successfully!');
  } catch (e) {
    print('Error: $e');
  }
}
