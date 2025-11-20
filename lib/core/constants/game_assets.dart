/// Asset constants using emojis and Material Icons
/// This provides a complete visual system without requiring external image files
class GameAssets {
  GameAssets._();

  // Zone Emojis
  static const String mathForestEmoji = '🌲';
  static const String logicMountainEmoji = '⛰️';
  static const String memoryRiverEmoji = '🌊';
  static const String shapeValleyEmoji = '🏔️';

  // Math Forest - Number Emojis
  static const String numberZero = '0️⃣';
  static const String numberOne = '1️⃣';
  static const String numberTwo = '2️⃣';
  static const String numberThree = '3️⃣';
  static const String numberFour = '4️⃣';
  static const String numberFive = '5️⃣';
  static const String numberSix = '6️⃣';
  static const String numberSeven = '7️⃣';
  static const String numberEight = '8️⃣';
  static const String numberNine = '9️⃣';

  // Math Operations
  static const String plusSign = '➕';
  static const String minusSign = '➖';
  static const String equalsSign = '🟰';

  // Memory River - Card Themes (Emojis)
  static const List<String> animalEmojis = [
    '🐱', // Cat
    '🐶', // Dog
    '🐦', // Bird
    '🐠', // Fish
    '🐰', // Rabbit
    '🦁', // Lion
    '🐘', // Elephant
    '🦒', // Giraffe
  ];

  static const List<String> fruitEmojis = [
    '🍎', // Apple
    '🍌', // Banana
    '🍊', // Orange
    '🍇', // Grapes
    '🍓', // Strawberry
    '🍉', // Watermelon
  ];

  static const List<String> vehicleEmojis = [
    '🚗', // Car
    '🚌', // Bus
    '🚚', // Truck
    '✈️', // Airplane
    '🚢', // Boat
    '🚲', // Bicycle
  ];

  static const List<String> foodEmojis = [
    '🍕', // Pizza
    '🍔', // Burger
    '🍦', // Ice Cream
    '🎂', // Cake
    '🍪', // Cookie
    '🥪', // Sandwich
  ];

  // Shape Valley - Shape Emojis
  static const String circleEmoji = '🔴';
  static const String squareEmoji = '🟦';
  static const String triangleEmoji = '🔺';
  static const String starEmoji = '⭐';
  static const String heartEmoji = '❤️';
  static const String diamondEmoji = '💎';

  // Reward & Achievement Emojis
  static const String trophy = '🏆';
  static const String medal = '🏅';
  static const String star = '⭐';
  static const String coin = '🪙';
  static const String chest = '🎁';
  static const String crown = '👑';
  static const String fire = '🔥'; // For streaks
  static const String party = '🎉'; // For celebrations
  static const String sparkles = '✨';

  // Pet Emojis
  static const List<String> petEmojis = [
    '🐉', // Dragon
    '🦄', // Unicorn
    '🐼', // Panda
    '🦊', // Fox
    '🐨', // Koala
  ];

  // Avatar Customization Emojis
  static const List<String> hatEmojis = [
    '🎩', // Top Hat
    '👑', // Crown
    '🧢', // Cap
    '🎓', // Graduation Cap
    '⛑️', // Helmet
  ];

  static const List<String> faceEmojis = [
    '😀', // Happy
    '😎', // Cool
    '🤓', // Nerd
    '😺', // Cat
    '🤖', // Robot
  ];

  // UI Emojis
  static const String lock = '🔒';
  static const String unlock = '🔓';
  static const String checkMark = '✅';
  static const String crossMark = '❌';
  static const String questionMark = '❓';
  static const String lightbulb = '💡'; // For hints
  static const String calendar = '📅';
  static const String settings = '⚙️';

  // Counting Objects (for Math Forest counting levels)
  static const List<String> countingEmojis = [
    '🍎', // Apple
    '⭐', // Star
    '🌸', // Flower
    '🎈', // Balloon
    '🍭', // Lollipop
    '🎨', // Art
    '🎵', // Music
    '⚽', // Ball
  ];

  // Get emoji for a number (0-9)
  static String getNumberEmoji(int number) {
    const emojis = [
      '0️⃣', '1️⃣', '2️⃣', '3️⃣', '4️⃣',
      '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣',
    ];
    if (number >= 0 && number <= 9) {
      return emojis[number];
    }
    return number.toString();
  }

  // Get random counting emoji
  static String getRandomCountingEmoji(int seed) {
    return countingEmojis[seed % countingEmojis.length];
  }

  // Get animal emoji by index
  static String getAnimalEmoji(int index) {
    return animalEmojis[index % animalEmojis.length];
  }

  // Get fruit emoji by index
  static String getFruitEmoji(int index) {
    return fruitEmojis[index % fruitEmojis.length];
  }
}
