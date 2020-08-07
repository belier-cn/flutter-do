library flutter_verification_box;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_verification_box/src/verification_box_item.dart';

///
/// 验证码输入框
///
class VerificationBox extends StatefulWidget {
  VerificationBox({
    Key key,
    this.count = 6,
    this.itemWidth = 45,
    this.onSubmitted,
    this.type = VerificationBoxItemType.box,
    this.decoration,
    this.borderWidth = 2.0,
    this.borderRadius = 5.0,
    this.textStyle,
    this.focusBorderColor,
    this.borderColor,
    this.unfocus = true,
    this.autoFocus = true,
    this.showCursor = false,
    this.cursorWidth = 2,
    this.cursorColor,
    this.cursorIndent = 10,
    this.cursorEndIndent = 10,
    this.onChange,
  }) : super(key: key);

  ///
  /// 几位验证码，一般6位，还有4位的
  ///
  final int count;

  ///
  /// 没一个item的宽
  ///
  final double itemWidth;

  ///
  /// 输入完成回调
  ///
  final ValueChanged<String> onSubmitted;

  ///
  /// 值改变的回调
  ///
  final ValueChanged<String> onChange;

  ///
  /// 每个item的装饰类型，[VerificationBoxItemType]
  ///
  final VerificationBoxItemType type;

  ///
  /// 每个item的样式
  ///
  final Decoration decoration;

  ///
  /// 边框宽度
  ///
  final double borderWidth;

  ///
  /// 边框颜色
  ///
  final Color borderColor;

  ///
  /// 获取焦点边框的颜色
  ///
  final Color focusBorderColor;

  ///
  /// [VerificationBoxItemType.box] 边框圆角
  ///
  final double borderRadius;

  ///
  /// 文本样式
  ///
  final TextStyle textStyle;

  ///
  /// 输入完成后是否失去焦点，默认true，失去焦点后，软键盘消失
  ///
  final bool unfocus;

  ///
  /// 是否自动获取焦点
  ///
  final bool autoFocus;

  ///
  /// 是否显示光标
  ///
  final bool showCursor;

  ///
  /// 光标颜色
  ///
  final Color cursorColor;

  ///
  /// 光标宽度
  ///
  final double cursorWidth;

  ///
  /// 光标距离顶部距离
  ///
  final double cursorIndent;

  ///
  /// 光标距离底部距离
  ///
  final double cursorEndIndent;

  @override
  State<StatefulWidget> createState() => VerificationBoxState();
}

class VerificationBoxState extends State<VerificationBox> {
  TextEditingController _controller;

  FocusNode _focusNode;

  List _contentList = [];

  final GlobalKey<EditableTextState> _editableTextKey =
      GlobalKey<EditableTextState>();

  GlobalKey<EditableTextState> get editableTextKey => _editableTextKey;

  FocusNode get focusNode => _focusNode;

  String get value => _controller.text;

  clearValue() {
    // 判断 value 是否为空
    if (value == "") {
      return;
    }
    _contentList = [];
    List.generate(widget.count, (index) {
      _contentList.add("");
    });
    _controller.text = "";
    if (widget.onChange != null) {
      widget.onChange(value);
    }
    setState(() {});
  }

  @override
  void initState() {
    List.generate(widget.count, (index) {
      _contentList.add("");
    });
    _controller = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
        _editableTextKey.currentState?.requestKeyboard();
      },
      child: Stack(
        children: <Widget>[
          _buildTextField(),
          _buildBox(),
        ],
      ),
    );
  }

  Widget _buildBox() {
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.count, (index) {
          return Container(
            width: widget.itemWidth,
            child: VerificationBoxItem(
              data: _contentList[index],
              textStyle: widget.textStyle,
              type: widget.type,
              decoration: widget.decoration,
              borderRadius: widget.borderRadius,
              borderWidth: widget.borderWidth,
              borderColor: (_controller.text.length == index
                  ? widget.focusBorderColor
                  : widget.borderColor) ??
                  widget.borderColor,
              showCursor: widget.showCursor && _controller.text.length == index,
              cursorColor: widget.cursorColor,
              cursorWidth: widget.cursorWidth,
              cursorIndent: widget.cursorIndent,
              cursorEndIndent: widget.cursorEndIndent,
            ),
          );
        }),
      ),
    );
  }

  ///
  /// 构建TextField
  ///
  _buildTextField() {
    return EditableText(
      key: _editableTextKey,
      controller: _controller,
      focusNode: _focusNode,
      cursorWidth: 0,
      autofocus: widget.autoFocus,
      inputFormatters: [
        WhitelistingTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.count),
      ],
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.transparent),
      onChanged: _onValueChange,
      cursorColor: Colors.transparent,
      backgroundCursorColor: Colors.transparent,
    );
  }

  _onValueChange(value) {
    String text = _controller.text;

    for (int i = 0; i < widget.count; i++) {
      _contentList[i] = i < value.length ? text.substring(i, i + 1) : "";
    }

    if (widget.onChange != null) {
      widget.onChange(text);
    }

    setState(() {});

    if (text.length == widget.count) {
      if (widget.unfocus) {
        _focusNode.unfocus();
      }
      if (widget.onSubmitted != null) {
        widget.onSubmitted(text);
      }
    }
  }
}
