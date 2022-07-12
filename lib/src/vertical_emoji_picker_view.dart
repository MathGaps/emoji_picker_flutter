import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/src/category_emoji.dart';
import 'package:emoji_picker_flutter/src/emoji_picker_internal_utils.dart';
import 'package:emoji_picker_flutter/src/emoji_skin_tones.dart';
import 'package:emoji_picker_flutter/src/emoji_view_state.dart';
import 'package:emoji_picker_flutter/src/triangle_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Default EmojiPicker Implementation
class VerticalEmojiPickerView extends EmojiPickerBuilder {
  /// Constructor
  VerticalEmojiPickerView(Config config, EmojiViewState state) : super(config, state);

  @override
  _VerticalEmojiPickerViewState createState() => _VerticalEmojiPickerViewState();
}

class _VerticalEmojiPickerViewState extends State<VerticalEmojiPickerView>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlay;
  late final _scrollController = ScrollController();
  late final _utils = EmojiPickerInternalUtils();
  final int _skinToneCount = 6;
  final double tabBarHeight = 46;

  late EmojiViewState state;
  late Config config;

  @override
  void initState() {
    state = widget.state;
    config = widget.config;

    var initCategory = widget.state.categoryEmoji
        .indexWhere((element) => element.category == widget.config.initCategory);
    if (initCategory == -1) {
      initCategory = 0;
    }

    _scrollController.addListener(_closeSkinToneDialog);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VerticalEmojiPickerView oldWidget) {
    state = widget.state;
    config = widget.config;

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _closeSkinToneDialog();
    super.dispose();
  }

  void _closeSkinToneDialog() {
    _overlay?.remove();
    _overlay = null;
  }

  void _openSkinToneDialog(
    Emoji emoji,
    double emojiSize,
    CategoryEmoji categoryEmoji,
    int index,
  ) {
    _overlay = _buildSkinToneOverlay(
      emoji,
      emojiSize,
      categoryEmoji,
      index,
    );
    Overlay.of(context)?.insert(_overlay!);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final emojiSize = config.getEmojiSize(constraints.maxWidth);

        var categoryEmojiList = state.categoryEmoji;
        var showTitle = true;

        if (state.searchEmoji != null) {
          showTitle = false;
          categoryEmojiList = [state.searchEmoji!];
        }

        return Container(
          color: config.bgColor,
          child: ListView.builder(
            itemCount: categoryEmojiList.length,
            controller: _scrollController,
            padding: config.padding,
            itemBuilder: (context, index) {
              final categoryEmoji = categoryEmojiList[index];

              // Display notice if recent has no entries yet
              if (categoryEmoji.category == Category.RECENT && categoryEmoji.emoji.isEmpty) {
                return _buildNoRecent();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  showTitle
                      ? Text(
                          categoryEmoji.category.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.7,
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: _closeSkinToneDialog,
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      primary: false,
                      padding: const EdgeInsets.all(0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: config.columns,
                        mainAxisSpacing: config.verticalSpacing,
                        crossAxisSpacing: config.horizontalSpacing,
                      ),
                      itemCount: categoryEmoji.emoji.length,
                      itemBuilder: (context, index) {
                        final emoji = categoryEmoji.emoji[index];
                        final onPressed = () {
                          _closeSkinToneDialog();
                          state.onEmojiSelected(categoryEmoji.category, emoji);
                        };

                        final onLongPressed = () {
                          if (!emoji.hasSkinTone || !config.enableSkinTones) {
                            _closeSkinToneDialog();
                            return;
                          }
                          _closeSkinToneDialog();
                          _openSkinToneDialog(emoji, emojiSize, categoryEmoji, index);
                        };

                        return _buildButtonWidget(
                          onPressed: onPressed,
                          onLongPressed: onLongPressed,
                          child: _buildEmoji(
                            emojiSize,
                            categoryEmoji,
                            emoji,
                            config.enableSkinTones,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: config.categorySpacing),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategory(int index, Category category) {
    return Tab(
      icon: Icon(
        config.getIconForCategory(category),
      ),
    );
  }

  /// Build and display Emoji centered of its parent
  Widget _buildEmoji(
    double emojiSize,
    CategoryEmoji categoryEmoji,
    Emoji emoji,
    bool showSkinToneIndicator,
  ) {
    // FittedBox needed for display, font scale settings
    return FittedBox(
      fit: BoxFit.fill,
      child: Stack(children: [
        emoji.hasSkinTone && showSkinToneIndicator
            ? Positioned(
                bottom: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(8, 8),
                  painter: TriangleShape(config.skinToneIndicatorColor),
                ),
              )
            : Container(),
        Text(
          emoji.emoji,
          textScaleFactor: 1.0,
          style: TextStyle(
            fontSize: emojiSize,
            backgroundColor: Colors.transparent,
            fontFamily: config.customEmojiFont,
          ),
        ),
      ]),
    );
  }

  /// Build different Button based on ButtonMode
  Widget _buildButtonWidget({
    required VoidCallback onPressed,
    required VoidCallback onLongPressed,
    required Widget child,
  }) {
    if (config.buttonMode == ButtonMode.MATERIAL) {
      return TextButton(
        onPressed: onPressed,
        onLongPress: onLongPressed,
        child: child,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          minimumSize: MaterialStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
    return GestureDetector(
      onLongPress: onLongPressed,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: child,
      ),
    );
  }

  /// Build Widget for when no recent emoji are available
  Widget _buildNoRecent() {
    return const SizedBox();
  }

  /// Overlay for SkinTone
  OverlayEntry _buildSkinToneOverlay(
    Emoji emoji,
    double emojiSize,
    CategoryEmoji categoryEmoji,
    int index,
  ) {
    // Calculate position of emoji in the grid
    final row = index ~/ config.columns;
    final column = index % config.columns;
    // Calculate position for skin tone dialog
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final emojiSpace = renderBox.size.width / config.columns;
    final topOffset = emojiSpace;
    final leftOffset = _getLeftOffset(emojiSpace, column);
    final left = offset.dx + column * emojiSpace + leftOffset;
    final top = tabBarHeight + offset.dy + row * emojiSpace - _scrollController.offset - topOffset;

    // Generate other skintone options
    final skinTonesEmoji =
        SkinTone.values.map((skinTone) => _utils.applySkinTone(emoji, skinTone)).toList();

    return OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: Material(
          elevation: 4.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            color: config.skinToneDialogBgColor,
            child: Row(
              children: [
                _buildSkinToneEmoji(categoryEmoji, emoji, emojiSpace, emojiSize),
                _buildSkinToneEmoji(categoryEmoji, skinTonesEmoji[0], emojiSpace, emojiSize),
                _buildSkinToneEmoji(categoryEmoji, skinTonesEmoji[1], emojiSpace, emojiSize),
                _buildSkinToneEmoji(categoryEmoji, skinTonesEmoji[2], emojiSpace, emojiSize),
                _buildSkinToneEmoji(categoryEmoji, skinTonesEmoji[3], emojiSpace, emojiSize),
                _buildSkinToneEmoji(categoryEmoji, skinTonesEmoji[4], emojiSpace, emojiSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build Emoji inside skin tone dialog
  Widget _buildSkinToneEmoji(
    CategoryEmoji categoryEmoji,
    Emoji emoji,
    double width,
    double emojiSize,
  ) {
    return SizedBox(
      width: width,
      height: width,
      child: _buildButtonWidget(
        onPressed: () {
          state.onEmojiSelected(categoryEmoji.category, emoji);
          _closeSkinToneDialog();
        },
        onLongPressed: () {},
        child: _buildEmoji(emojiSize, categoryEmoji, emoji, false),
      ),
    );
  }

  // Calucates the offset from the middle of selected emoji to the left side
  // of the skin tone dialog
  // Case 1: Selected Emoji is close to left border and offset needs to be
  // reduced
  // Case 2: Selected Emoji is close to right border and offset needs to be
  // larger than half of the whole width
  // Case 3: Enough space to left and right border and offset can be half
  // of whole width
  double _getLeftOffset(double emojiWidth, int column) {
    var remainingColumns = config.columns - (column + 1 + (_skinToneCount ~/ 2));
    if (column >= 0 && column < 3) {
      return -1 * column * emojiWidth;
    } else if (remainingColumns < 0) {
      return -1 * ((_skinToneCount ~/ 2 - 1) + -1 * remainingColumns) * emojiWidth;
    }
    return -1 * ((_skinToneCount ~/ 2) * emojiWidth) + emojiWidth / 2;
  }
}
