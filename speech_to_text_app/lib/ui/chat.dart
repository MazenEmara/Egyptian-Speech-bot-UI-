import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Add this line for path_provider
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'dart:math';
import 'dart:core';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatHistory = [];
  late FlutterSoundRecorder _soundRecorder;
  bool _isRecording = false;
  Codec _codec = Codec.aacADTS;
  List<String> messages = [];
  int session = 0;
  String preference = "";
  String prefer = "";
  final TextEditingController _chatController = TextEditingController();
  int age = 25;
  String emotion = "مبسوط";
  String gender = "male";
  String name = "";

  String getGenderSpecificSentence(String sentence) {
    if (gender == "female") {
      sentence = sentence
          .replaceFirst("تعمل", "تعملي")
          .replaceFirst("تحب", "تحبي")
          .replaceFirst("عاوز", "عاوزة")
          .replaceFirst("ليك", "ليكي")
          .replaceFirst("تروح", "تروحي")
          .replaceFirst("تسمع", "تسمعي")
          .replaceFirst("تتفرج", "تتفرجي")
          .replaceFirst("تلعب", "تلعبي")
          .replaceFirst("تخرج", "تخرجي")
          .replaceFirst("جرب", "جربي")
          .replaceFirst("اختار", "اختاري")
          .replaceFirst("معاك", "معاكي");
    }
    return sentence;
  }

  String getRandomQuestion() {
    var questions = [
      "ايه رأيك نجرب حاجة تانية تحب تخرج؟ ولا حاجه فلبيت بردو (فيلم، أغاني، ولا لعبة)؟",
      "نغير جو شوية؟ولا تحب نشوف فيلم، نسمع شوية أغاني ولا نلعب حاجة؟",
      "عندك مزاج لإيه تاني؟ فيلم، أغاني، لعب، خروج ؟"
    ];
    var randomIndex = Random().nextInt(questions.length);
    var question = questions[randomIndex];
    return getGenderSpecificSentence(question);
  }

  String getRandomFeedback(String preference, String gender, int age) {
    final moviePattern = RegExp(r'(افلام|فلام|فلم|فيلم)');
    final musicPattern = RegExp(r'(اغاني|غاني|غني|غالي|غياني)');
    final gameBookPattern = RegExp(r'(لعب|لعبه|كتب|لعبة|تاب|تب|ليعب|ليعاب)');
    final outingPattern = RegExp(r'(انزل|اروح|بره|خرج|خروج|اخرج)');

    if (moviePattern.hasMatch(preference)) {
      preference = 'افلام';
    } else if (musicPattern.hasMatch(preference)) {
      preference = 'اغاني';
    } else if (outingPattern.hasMatch(preference)) {
      preference = 'خروج';
    } else if (gameBookPattern.hasMatch(preference)) {
      if (age >= 41) {
        preference = 'كتب';
      } else {
        preference = 'لعب';
      }
    }

    final feedbackOptions = {
      'افلام': [
        "ايه رأيك في الفيلم ده؟",
        "عجبك الفيلم ده؟",
        "الفيلم ده مناسب ليك؟"
      ],
      'اغاني': [
        "ايه رأيك في الاغنية دي؟",
        "عجبتك الاغنية دي؟",
        "الاغنية دي مناسبة ليك؟"
      ],
      'لعب': [
        "ايه رأيك في اللعبة دي؟",
        "عجبتك اللعبة دي؟",
        "اللعبة دي مناسبة ليك؟"
      ],
      'كتب': [
        "ايه رأيك في الكتاب ده؟",
        "عجبك الكتاب ده؟",
        "هل الكتاب ده مناسب ليك؟"
      ],
      'خروج': [
        "طب ايه رايك تروح؟",
        "طب عجبك المكان ده؟",
        "في مكان ممكن يعجبك اكتر زي"
      ]
    };

    var random = Random();
    var choices = feedbackOptions[preference]!;
    var choice = choices[random.nextInt(choices.length)];
    return getGenderSpecificSentence(choice);
  }

  String? extractName(String text) {
    List<String> words = text.split(" ");
    String lastWord = words.last;
    int totalWords = words.length;
    RegExp namePattern = RegExp(r'(اسمي|انا|سمي|اسني)');

    print("length : ${totalWords}");
    print("texticooo : ${text}");
    print("texticooo : ${lastWord}");

    if (namePattern.hasMatch(text)) {
      return lastWord;
    } else if (totalWords == 1) {
      return text;
    } else {
      return null;
    }
  }

  String? getEntertainmentSuggestion(
      int age, String emotion, String userResponse) {
    final moviePattern = RegExp(r'(افلام|فلام|فلم|فيلم)');
    final musicPattern = RegExp(r'(اغاني|غاني|غني|غالي|غياني)');
    final gameBookPattern = RegExp(r'(لعب|لعبه|كتب|لعبة|تاب|تب|ليعب|ليعاب)');
    final outingPattern = RegExp(r'(انزل|اروح|بره|خرج|خروج|اخرج)');

    String preference;
    if (moviePattern.hasMatch(userResponse)) {
      preference = 'افلام';
    } else if (musicPattern.hasMatch(userResponse)) {
      preference = 'اغاني';
    } else if (outingPattern.hasMatch(userResponse)) {
      preference = 'خروج';
    } else if (gameBookPattern.hasMatch(userResponse)) {
      preference = (age >= 41) ? 'كتب' : 'لعب';
    } else {
      return getGenderSpecificSentence("جرب تاني و اختار من أربعة");
    }

    Map<List<int>, Map<String, Map<String, List<String>>>>
        entertainmentOptions = {
      [0, 20]: {
        'مبسوط': {
          'افلام': [
            'Toy Story' 'Finding Nemo',
            'Frozen',
            'Moana',
            'The Lion King',
            'Tangled',
            'Inside Out',
            'Zootopia',
            'Paddington',
            'The Incredibles'
          ],
          'اغاني': [
            'Happy',
            'Cant Stop the Feeling!' 'Shake It Off',
            'Walking on Sunshine',
            'Uptown Funk',
            'Best Day of My Life',
            'I Gotta Feeling',
            'Waka Waka',
            'Count on Me',
            'Roar'
          ],
          'لعب': [
            'Mario Kart 8 Deluxe',
            'Animal Crossing: New Horizons',
            'Minecraft',
            'Super Mario Odyssey',
            'The Legend of Zelda: Breath of the Wild',
            'Splatoon 2',
            'Rocket League',
            'Rayman Legends',
            'Just Dance (any version)',
            'LEGO Marvel Superheroes'
          ],
          'خروج': [
            'سكي مصر',
            'Air zone',
            'كيدزانيا',
            'فاميلي بارك',
            'فاميلي لاند المعادي',
            'جيرولاند',
            'بيلي بيز',
            'كريزي ووتر',
            'السيرك القومي',
            'ماجيك لاند'
          ]
        },
        'متعصب': {
          'افلام': [
            'The Lion King',
            'Matilda',
            'Inside Out',
            'Zootopia',
            'The Incredibles',
            'How to Train Your Dragon',
            'Wreck-It Ralph',
            'Big Hero 6',
            'Mulan',
            'Brave'
          ],
          'اغاني': [
            'Eye of the Tiger',
            'Roar',
            'Stronger',
            'Fight Song',
            'Titanium',
            'Firework',
            'Can’t Hold Us',
            'Hall of Fame',
            'Brave',
            'Shake It Off'
          ],
          'لعب': [
            'Super Smash Bros. Ultimate',
            'Minecraft (PvP modes)',
            'FIFA 23',
            'NBA 2K23',
            'Mario Kart 8 Deluxe',
            'Splatoon 2',
            'Overcooked! 2',
            'Lego Marvel Superheroes',
            'Rocket League',
            'Plants vs. Zombies: Garden Warfare 2'
          ],
          'خروج': [
            'سكي مصر',
            'Air zone',
            'كيدزانيا',
            'فاميلي بارك',
            'فاميلي لاند المعادي',
            'جيرولاند',
            'بيلي بيز',
            'كريزي ووتر',
            'السيرك القومي',
            'ماجيك لاند'
          ]
        },
        'حزين': {
          'افلام': [
            'Inside Out',
            'Up',
            'The Lion King',
            'Bambi',
            'Coco',
            'Finding Nemo',
            'Toy Story 3',
            'The Fox and the Hound',
            'Bridge to Terabithia',
            'Charlotte’s Web'
          ],
          'اغاني': [
            'When She Loved Me',
            'Fix You',
            'Let It Go',
            'Yesterday',
            'Hallelujah',
            'Someone Like You',
            'See You Again',
            'Stay',
            'Skinny Love',
            'Lost Boy'
          ],
          'لعب': [
            'The Last Guardian',
            'Ori and the Blind Forest',
            'Journey',
            'Celeste',
            'Undertale',
            'Life is Strange',
            'To the Moon',
            'Spiritfarer',
            'Graveyard Keeper',
            'Brothers: A Tale of Two Sons'
          ],
          'خروج': [
            'سكي مصر',
            'Air zone',
            'كيدزانيا',
            'فاميلي بارك',
            'فاميلي لاند المعادي',
            'جيرولاند',
            'بيلي بيز',
            'كريزي ووتر',
            'السيرك القومي',
            'ماجيك لاند'
          ]
        },
        'متفاجئ': {
          'افلام': [
            'Toy Story 3',
            'Big Hero 6',
            'The Lego Movie',
            'Monsters, Inc.',
            'Ratatouille',
            'The Incredibles',
            'Wreck-It Ralph',
            'Shrek',
            'Frozen',
            'Spider-Man: Into the Spider-Verse'
          ],
          'اغاني': [
            'Happy',
            'Cant Stop The Feeling!',
            'Walking on Sunshine',
            'Uptown Funk',
            'Shake It Off',
            'Best Day of My Life',
            'Count on Me',
            'Firework',
            'Dynamite',
            'I Gotta Feeling'
          ],
          'لعب': [
            'Among Us',
            'Minecraft',
            'The Legend of Zelda: Breath of the Wild',
            'Super Mario Odyssey',
            'Rayman Legends',
            'Animal Crossing: New Horizons',
            'LittleBigPlanet 3',
            'Roblox',
            'Terraria',
            'Fortnite'
          ],
          'خروج': [
            'سكي مصر',
            'Air zone',
            'كيدزانيا',
            'فاميلي بارك',
            'فاميلي لاند المعادي',
            'جيرولاند',
            'بيلي بيز',
            'كريزي ووتر',
            'السيرك القومي',
            'ماجيك لاند'
          ]
        },
      },
      [21, 40]: {
        'مبسوط': {
          'افلام': [
            'Amélie',
            'The Grand Budapest Hotel',
            'The Secret Life of Walter Mitty',
            'La La Land',
            'Midnight in Paris',
            'Guardians of the Galaxy',
            'Little Miss Sunshine',
            'Forrest Gump',
            'Chef',
            'The Intouchables'
          ],
          'اغاني': [
            'Happy',
            'Cant Stop The Feeling!',
            'Uptown Funk',
            'Shake It Off',
            'Best Day of My Life',
            'I Gotta Feeling',
            'Get Lucky',
            'Walking On Sunshine',
            'Valerie',
            'Hey Ya!'
          ],
          'لعب': [
            'Stardew Valley',
            'Animal Crossing: New Horizons',
            'The Sims 4',
            'Mario Kart 8 Deluxe',
            'Overwatch',
            'Beat Saber',
            'Journey',
            'Rocket League',
            'Terraria',
            'Minecraft'
          ],
          'خروج': [
            'خان الخليلي',
            'برج القاهرة',
            'la casetta مطعم',
            'نايل كروز',
            'مطعم بروكار السوري',
            'dara',
            'قهوة كونست',
            'كريزي ووتر ف 6 أكتوبر',
            'شارع المعز',
            'مطعم باب القصر',
            'كشري أبو طارق',
            'مطعم إنديرا ',
            'مول مصر',
            'ملاهي (Malahy)'
          ]
        },
        'متعصب': {
          'افلام': [
            'Fight Club',
            'Mad Max: Fury Road',
            'The Dark Knight',
            'Gladiator',
            'V for Vendetta',
            '300',
            'John Wick',
            'The Wolf of Wall Street',
            'Kill Bill: Vol. 1',
            'Snatch'
          ],
          'اغاني': [
            'Eye of the Tiger',
            'Killing In The Name',
            'Seven Nation Army',
            'Bulls On Parade',
            'Sabotage',
            'Enter Sandman',
            'We Will Rock You',
            'Break Stuff',
            'Survivor',
            'Smells Like Teen Spirit'
          ],
          'لعب': [
            'DOOM Eternal',
            'God of War',
            'Mortal Kombat 11',
            'Dark Souls III',
            'Sekiro: Shadows Die Twice',
            'Street Fighter V',
            'Call of Duty: Warzone',
            'For Honor',
            'Cuphead',
            'Hotline Miami'
          ],
          'خروج': [
            'خان الخليلي',
            'برج القاهرة',
            'la casetta مطعم',
            'نايل كروز',
            'مطعم بروكار السوري',
            'dara',
            'قهوة كونست',
            'كريزي ووتر ف 6 أكتوبر',
            'شارع المعز',
            'مطعم باب القصر',
            'كشري أبو طارق',
            'مطعم إنديرا ',
            'مول مصر',
            'ملاهي (Malahy)'
          ]
        },
        'حزين': {
          'افلام': [
            'Eternal Sunshine of the Spotless Mind',
            'Requiem for a Dream',
            'The Shawshank Redemption',
            'Schindler’s List',
            'Manchester by the Sea',
            'Her',
            'Lost in Translation',
            'The Green Mile',
            'Grave of the Fireflies',
            'Blue Valentine'
          ],
          'اغاني': [
            'Someone Like You',
            'Fix You',
            'Hallelujah',
            'Skinny Love',
            'Nothing Compares 2 U',
            'With or Without You',
            'Tears in Heaven',
            'The Night We Met',
            'Creep',
            'Everybody Hurts'
          ],
          'لعب': [
            'The Last of Us',
            'Life is Strange',
            'Red Dead Redemption 2',
            'Hellblade: Senuas Sacrifice',
            'What Remains of Edith Finch',
            'Gris',
            'Death Stranding',
            'Journey',
            'Firewatch',
            'To The Moon'
          ],
          'خروج': [
            'خان الخليلي',
            'برج القاهرة',
            'la casetta مطعم',
            'نايل كروز',
            'مطعم بروكار السوري',
            'dara',
            'قهوة كونست',
            'كريزي ووتر ف 6 أكتوبر',
            'شارع المعز',
            'مطعم باب القصر',
            'كشري أبو طارق',
            'مطعم إنديرا ',
            'مول مصر',
            'ملاهي (Malahy)'
          ]
        },
        'متفاجئ': {
          'افلام': [
            'Inception',
            'The Sixth Sense',
            'The Prestige',
            'Fight Club',
            'Memento',
            'Shutter Island',
            'Gone Girl',
            'Oldboy',
            'The Others',
            'Se7en'
          ],
          'اغاني': [
            'Bohemian Rhapsody',
            'Rolling in the Deep',
            'Somebody That I Used to Know',
            'Lose Yourself',
            'Thriller',
            'Dont Stop Believin',
            'Pumped Up Kicks',
            'Take Me to Church',
            'Bad Guy',
            'Blinding Lights'
          ],
          'لعب': [
            'Bioshock',
            'The Witcher 3: Wild Hunt',
            'Portal 2',
            'Undertale',
            'Metal Gear Solid V: The Phantom Pain',
            'Bloodborne',
            'Control',
            'The Stanley Parable',
            'Inside',
            'Return of the Obra Dinn'
          ],
          'خروج': [
            'خان الخليلي',
            'برج القاهرة',
            'la casetta مطعم',
            'نايل كروز',
            'مطعم بروكار السوري',
            'dara',
            'قهوة كونست',
            'كريزي ووتر ف 6 أكتوبر',
            'شارع المعز',
            'مطعم باب القصر',
            'كشري أبو طارق',
            'مطعم إنديرا ',
            'مول مصر',
            'ملاهي (Malahy)'
          ]
        },
      },
      [41, 80]: {
        'مبسوط': {
          'افلام': [
            'Forrest Gump',
            'The Sound of Music',
            'Amélie',
            'It’s a Wonderful Life',
            'Mamma Mia!',
            'When Harry Met Sally',
            'Chocolat',
            'Under the Tuscan Sun',
            'My Big Fat Greek Wedding',
            'The Best Exotic Marigold Hotel'
          ],
          'اغاني': [
            'Dancing Queen',
            'Here Comes The Sun',
            'Brown Eyed Girl',
            'September',
            'Don’t Worry Be Happy',
            'Uptown Girl',
            'Sweet Caroline',
            'Good Vibrations',
            'Isnt She Lovely',
            'I Got You (I Feel Good)'
          ],
          'كتب': [
            'The Rosie Project',
            'A Man Called Ove',
            'Eat, Pray, Love',
            'The Unlikely Pilgrimage of Harold Fry',
            'Bridget Jones s Diary',
            'The No. 1 Ladies Detective Agency',
            'Major Pettigrews Last Stand',
            'The Guernsey Literary and Potato Peel Pie Society',
            'The Bookshop on the Corner'
          ],
          'خروج': [
            'خان الخليلي',
            'قهوة الفيشاوي',
            'دار الأوبرا',
            'نايل كروز',
            'جروبي',
            'دار الأوبرا',
            'نادي الجزيرة'
          ]
        },
        'متعصب': {
          'افلام': [
            'Network',
            '12 Angry Men',
            'Gran Torino',
            'The Godfather',
            'Raging Bull',
            'One Flew Over the Cuckoo’s Nest',
            'Gladiator',
            'Taxi Driver',
            'A Few Good Men',
            'Braveheart'
          ],
          'اغاني': [
            'Born in the U.S.A.',
            'Another Brick in the Wall',
            'Fortunate Son',
            'American Idiot',
            'We Will Rock You',
            'Fight the Power',
            'Bad Moon Rising',
            'Walk This Way',
            'Back In Black',
            'Should I Stay or Should I Go'
          ],
          'كتب': [
            '1984',
            'The Grapes of Wrath',
            'To Kill a Mockingbird',
            'Fahrenheit 451',
            'Animal Farm',
            'Lord of the Flies',
            'The Handmaid’s Tale',
            'Catch-22',
            'Brave New World',
            'The Road'
          ],
          'خروج': [
            'خان الخليلي',
            'قهوة الفيشاوي',
            'دار الأوبرا',
            'نايل كروز',
            'جروبي',
            'دار الأوبرا',
            'نادي الجزيرة'
          ]
        },
        'حزين': {
          'افلام': [
            'Schindler’s List',
            'The Green Mile',
            'Terms of Endearment',
            'Saving Private Ryan',
            'Philadelphia',
            'Titanic',
            'Brokeback Mountain',
            'The Color Purple',
            'Ordinary People',
            'Kramer vs. Kramer'
          ],
          'اغاني': [
            'Tears in Heaven',
            'Yesterday',
            'Bridge Over Troubled Water',
            'Hallelujah',
            'Candle in the Wind',
            'Let It Be',
            'Nothing Compares 2 U',
            'Everybody Hurts',
            'I Will Always Love You',
            'Unchained Melody'
          ],
          'كتب': [
            'The Kite Runner',
            'Atonement',
            'The Road',
            'The Lovely Bones',
            'Revolutionary Road',
            'Never Let Me Go',
            'Beloved',
            'Norwegian Wood',
            'The Light Between Oceans',
            'The Remains of the Day'
          ],
          'خروج': [
            'خان الخليلي',
            'قهوة الفيشاوي',
            'دار الأوبرا',
            'نايل كروز',
            'جروبي',
            'دار الأوبرا',
            'نادي الجزيرة'
          ]
        },
        'متفاجئ': {
          'افلام': [
            'The Sixth Sense',
            'Psycho',
            'The Usual Suspects',
            'Fight Club',
            'Memento',
            'Gone Girl',
            'The Others',
            'Primal Fear',
            'Shutter Island',
            'The Prestige'
          ],
          'اغاني': [
            'Bohemian Rhapsody',
            'Stairway to Heaven',
            'Hotel California',
            'Like a Rolling Stone',
            'Thunderstruck',
            'Baba O’Riley',
            'Layla',
            'Space Oddity',
            'American Pie',
            'Go Your Own Way'
          ],
          'كتب': [
            'Gone Girl',
            'The Girl with the Dragon Tattoo',
            'Shutter Island',
            'The Da Vinci Code',
            'The Murder of Roger Ackroyd',
            'Big Little Lies',
            'I Am Watching You',
            'The Silent Patient',
            'The Woman in the Window',
            'Before I Go to Sleep'
          ],
          'خروج': [
            'خان الخليلي',
            'قهوة الفيشاوي',
            'دار الأوبرا',
            'نايل كروز',
            'جروبي',
            'دار الأوبرا',
            'نادي الجزيرة'
          ]
        }
      }
    };

    for (var ageRange in entertainmentOptions.keys) {
      if (ageRange[0] <= age && age <= ageRange[1]) {
        var optionsByEmotion = entertainmentOptions[ageRange]?[emotion];
        if (optionsByEmotion != null &&
            optionsByEmotion.containsKey(preference)) {
          var choices = optionsByEmotion[preference];
          if (choices != null && choices.isNotEmpty) {
            return getGenderSpecificSentence(
                choices[Random().nextInt(choices.length)]);
          }
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _chatHistory.add({
      "time": DateTime.now(),
      "isshown": false,
      "message": "اهلا اهلا اسمك ايه؟",
      "isSender": false,
    });
  }

  void updateConversation(String text) {
    setState(() {
      _chatHistory.add({
        "time": DateTime.now(),
        "isshown": false,
        "message": "$text",
        "isSender": true,
      });
      if (session == 0) {
        if (extractName(text) == null) {
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message":
                "${getGenderSpecificSentence('مش عارف اسمك، اسمك ايه؟')}",
            "isSender": false,
          });
          return;
        }
        name = extractName(text)!;
        emotion += gender == "female" ? "ة" : "";
        String greeting =
            "ازيك يا $name! بما انك $emotion. تحب تسمع اغاني ولا تتفرج على فيلم ولا تلعب ولا تخرج؟";
        _chatHistory.add({
          "time": DateTime.now(),
          "isshown": false,
          "message": "${getGenderSpecificSentence(greeting)}",
          "isSender": false,
        });
        session = 2;
        return; // Wait for next user input
      }
      if (session == 2) {
        preference = text; // Capture preference
        prefer = preference;
        String? suggestion =
            getEntertainmentSuggestion(age, emotion, preference);
        if (suggestion!.startsWith("جرب تاني") ||
            suggestion.startsWith("جربي تاني")) {
          print("within");
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": "$suggestion",
            "isSender": false,
          });
          return;
        } else {
          String feedback_question = getRandomFeedback(preference, gender, age);
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": "${suggestion}، ${feedback_question}",
            "isSender": false,
          });
          session = 3;
          return;
        }
      }
      if (session == 3) {
        preference = text;
        if (RegExp(r'(كويس|تمام|حلو|شكر|شكرا|ماشي|اه)').hasMatch(preference)) {
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message":
                "${getGenderSpecificSentence('عاوز اقتراح تاني لنشاط غير ده؟')}",
            "isSender": false,
          });
          prefer = "";
          session = 4;
          return;
        } else {
          String? suggestion = getEntertainmentSuggestion(age, emotion, prefer);
          String feedback_question = getRandomFeedback(prefer, gender, age);
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": "${suggestion}، ${feedback_question}",
            "isSender": false,
          });
          return;
        }
      }
      if (session == 4) {
        String continuePattern = r'(اه|نعم|يس|أكيد)';
        if (RegExp(continuePattern).hasMatch(text)) {
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": "${getGenderSpecificSentence(getRandomQuestion())}",
            "isSender": false,
          });
          session = 2;
          return;
        } else {
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message":
                "${getGenderSpecificSentence('تشرفنا بالكلام معاك، يوم سعيد!')}",
            "isSender": false,
          });
          session = 0;
          return;
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void handleUserInput(String input) {
    print("aaaaaaaaaaaaa session : ${session}");
    updateConversation(input);
    _scrollToEnd();
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Chat",
          style: GoogleFonts.aboreto(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 160,
            child: ListView.builder(
              itemCount: _chatHistory.length,
              shrinkWrap: false,
              controller: _scrollController,
              padding: EdgeInsets.only(top: 10, bottom: 100),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                var message = _chatHistory[index];
                var time = message["time"] as DateTime;
                String formattedTime = DateFormat('hh:mm a').format(time);
                bool isBotMessage = !_chatHistory[index]["isSender"];
                return Container(
                  padding:
                      EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment:
                        isBotMessage ? Alignment.topLeft : Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        color: isBotMessage ? Colors.white : Color(0xFFF69170),
                      ),
                      padding: EdgeInsets.all(16),
                      child: isBotMessage
                          ? FutureBuilder(
                              future: message["isshown"]
                                  ? Future.value()
                                  : Future.delayed(Duration(seconds: 2)),
                              builder: (context, snapshot) {
                                if (message["isshown"] ||
                                    snapshot.connectionState ==
                                        ConnectionState.done) {
                                  message["isshown"] = true;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset('assets/bot.png', width: 37),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          message["message"],
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          formattedTime,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: const Color.fromARGB(
                                                255, 219, 218, 218),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // While waiting, show the typing indicator
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset('assets/bot.png', width: 37),
                                      SizedBox(width: 8),
                                      typingIndicator(),
                                    ],
                                  );
                                }
                              },
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    message["message"],
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: const Color.fromARGB(
                                          255, 219, 218, 218),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF69170),
                                  Color(0xFF7D96E6),
                                ]),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                              onPressed: () {
                                _isRecording = !_isRecording;
                              },
                            ),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Type a message",
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(8.0),
                                ),
                                controller: _chatController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          if (_chatController.text.isNotEmpty) {
                            handleUserInput(_chatController.text);
                            _chatController.clear();
                          }
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: const EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF69170),
                                Color(0xFF7D96E6),
                              ]),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        ),
                        child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 88.0, minHeight: 36.0),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget typingIndicator() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (index) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 2),
        height: 10,
        width: 10,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      );
    }),
  );
}
