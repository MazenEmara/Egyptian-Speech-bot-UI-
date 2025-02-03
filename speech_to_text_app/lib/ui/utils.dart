export 'utils.dart';

import 'dart:math';
import 'dart:core';

String formatBilingualText(String suggestion, String feedbackQuestion) {
  const String RLO = '\u202E';
  const String PDF = '\u202C';

  if (isTextArabic(suggestion)) {
    return "$RLO$suggestion$PDF، $feedbackQuestion";
  } else {
    return "$suggestion, $feedbackQuestion";
  }
}

bool isTextArabic(String text) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
}

String getRandomConversationStarter() {
  List<String> questions = [
    "عامل ايه النهارده، كل حاجة تمام؟",
    "ازيك النهارده؟ أخبارك ايه؟",
    "ايه أخبارك كل شيء كويس؟"
  ];
  return questions[Random().nextInt(questions.length)];
}

String getGenderSpecificSentence(String sentence, String gender) {
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

String getRandomQuestion(String gender) {
  var questions = [
    "ايه رأيك نجرب حاجة تانية تحب تخرج؟ ولا حاجه فلبيت بردو (فيلم، أغاني، ولا لعبة)؟",
    "نغير جو شوية؟ولا تحب نشوف فيلم، نسمع شوية أغاني ولا نلعب حاجة؟",
    "عندك مزاج لإيه تاني؟ فيلم، أغاني، لعب، خروج ؟"
  ];
  var randomIndex = Random().nextInt(questions.length);
  var question = questions[randomIndex];
  return getGenderSpecificSentence(question, gender);
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
      "طب ايه رايك تروح حاجة ذي كده؟",
      "عجبك المكان ده؟",
      "ممكن يعجبك ده"
    ]
  };

  var random = Random();
  var choices = feedbackOptions[preference]!;
  var choice = choices[random.nextInt(choices.length)];
  return getGenderSpecificSentence(choice, gender);
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

String getRandomTryAgainMessage() {
  List<String> messages = [
    "جرب تانى و اختار من الحجات المقترحة",
    "حاول تاني و اختار منهم",
    "معلش بس جرب تاني و اختار من الاربعة كده",
  ];
  return messages[Random().nextInt(messages.length)];
}

String? getEntertainmentSuggestion(
    int age, String emotion, String userResponse, String gender) {
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
    return "جرب تاني و اختار من أربعة";
  }

  Map<List<int>, Map<String, Map<String, List<String>>>> entertainmentOptions =
      {
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
              choices[Random().nextInt(choices.length)], gender);
        }
      }
    }
  }
  return null;
}
