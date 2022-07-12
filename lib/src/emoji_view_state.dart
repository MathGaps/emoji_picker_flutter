import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/src/category_emoji.dart';

/// State that holds current emoji data
class EmojiViewState {
  /// Constructor
  EmojiViewState(
    this.categoryEmoji,
    this.onEmojiSelected,
    this.onBackspacePressed,
    this.searchEmoji,
  );

  /// List of all category including their emoji
  final List<CategoryEmoji> categoryEmoji;

  /// Callback when pressed on emoji
  final OnEmojiSelected onEmojiSelected;

  /// Callback when pressed on backspace
  final OnBackspacePressed? onBackspacePressed;

  /// Pass in list of emoji that was searchec for
  final CategoryEmoji? searchEmoji;
}
