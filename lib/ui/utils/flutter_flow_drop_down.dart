import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:inversiones/ui/models/drop_down_button_model.dart';

import 'form_field_controller.dart';

class FlutterFlowDropDown<T> extends StatefulWidget {
  const FlutterFlowDropDown({
    super.key,
    required this.controller,
    this.hintText,
    this.searchHintText,
    required this.options,
    this.optionLabels,
    this.onChanged,
    this.icon,
    this.width,
    this.height,
    this.maxHeight,
    this.fillColor,
    this.searchHintTextStyle,
    this.searchTextStyle,
    this.searchCursorColor,
    required this.textStyle,
    required this.elevation,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderColor,
    required this.margin,
    this.hidesUnderline = false,
    this.disabled = false,
    this.isOverButton = false,
    this.menuOffset,
    this.isSearchable = false,
    this.labelText,
    this.labelTextStyle,
  }) : assert(onChanged != null);

  final FormFieldController<T> controller;
  final String? hintText;
  final String? searchHintText;
  final List<DropDownButtonModel> options;
  final List<String>? optionLabels;
  final Function(T?)? onChanged;
  final Widget? icon;
  final double? width;
  final double? height;
  final double? maxHeight;
  final Color? fillColor;
  final TextStyle? searchHintTextStyle;
  final TextStyle? searchTextStyle;
  final Color? searchCursorColor;
  final TextStyle textStyle;
  final double elevation;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsetsGeometry margin;
  final bool hidesUnderline;
  final bool disabled;
  final bool isOverButton;
  final Offset? menuOffset;
  final bool isSearchable;
  final String? labelText;
  final TextStyle? labelTextStyle;

  @override
  State<FlutterFlowDropDown<T>> createState() => _FlutterFlowDropDownState<T>();
}

class _FlutterFlowDropDownState<T> extends State<FlutterFlowDropDown<T>> {
  FormFieldController<T?> get controller => widget.controller;

  T? get currentValue {
    final value = controller.value;
    return widget.options.map((e) => e.id).contains(value) ? value : null;
  }

  EdgeInsetsGeometry get horizontalMargin =>
      widget.margin.clamp(
        EdgeInsetsDirectional.zero,
        const EdgeInsetsDirectional.symmetric(horizontal: double.infinity),
      );

  late void Function() _listener;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listener = () {
      setState(() {}); // Asegúrate de que el widget se reconstruye cuando el valor cambia
      widget.onChanged!(controller.value);
    };
    controller.addListener(_listener);
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownWidget = _buildDropdownWidget();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          color: widget.fillColor,
        ),
        child: Padding(
          padding: _useDropdown2() ? EdgeInsets.zero : widget.margin,
          child: widget.hidesUnderline
              ? DropdownButtonHideUnderline(child: dropdownWidget)
              : dropdownWidget,
        ),
      ),
    );
  }

  bool _useDropdown2() =>
      widget.isSearchable || !widget.isOverButton || widget.maxHeight != null;

  Widget _buildDropdownWidget() => _buildDropdown();

  Text? _createHintText() =>
      widget.hintText != null
          ? Text(widget.hintText!, style: widget.textStyle)
          : null;

  List<DropdownMenuItem<dynamic>> _createMenuItems() =>
      widget.options
          .map(
            (option) =>
            DropdownMenuItem<dynamic>(
              value: option.id,
              child: Padding(
                padding: _useDropdown2() ? horizontalMargin : EdgeInsets.zero,
                child: Text(option.value ?? '', style: widget.textStyle),
              ),
            ),
      )
          .toList();

  Widget _buildDropdown() {
    final overlayColor = MaterialStateProperty.resolveWith<Color?>((states) =>
    states.contains(MaterialState.focused) ? Colors.transparent : null);
    final iconStyleData = widget.icon != null
        ? IconStyleData(icon: widget.icon!)
        : const IconStyleData();
    return DropdownButton2<dynamic>(
      value: currentValue,
      hint: _createHintText(),
      items: _createMenuItems(),
      iconStyleData: iconStyleData,
      buttonStyleData: ButtonStyleData(
        elevation: widget.elevation.toInt(),
        overlayColor: overlayColor,
        padding: widget.margin,
      ),
      menuItemStyleData: MenuItemStyleData(
        overlayColor: overlayColor,
        padding: EdgeInsets.zero,
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: widget.elevation.toInt(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: widget.fillColor,
        ),
        isOverButton: widget.isOverButton,
        offset: widget.menuOffset ?? Offset.zero,
        maxHeight: widget.maxHeight,
        padding: EdgeInsets.zero,
      ),
      onChanged: widget.disabled
          ? null
          : (val) {
        setState(() {
          controller.value = val;
        });
        widget.onChanged!(val);
      },
      isExpanded: true,
      selectedItemBuilder: (context) =>
          widget.options
              .map(
                (item) =>
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    item.value,
                    style: widget.textStyle,
                    maxLines: 1,
                  ),
                ),
          )
              .toList(),
      dropdownSearchData: widget.isSearchable
          ? DropdownSearchData<T>(
        searchController: _textEditingController,
        searchInnerWidgetHeight: 50,
        searchInnerWidget: Container(
          height: 50,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 4,
            right: 8,
            left: 8,
          ),
          child: TextFormField(
            expands: true,
            maxLines: null,
            controller: _textEditingController,
            cursorColor: widget.searchCursorColor,
            style: widget.searchTextStyle,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              hintText: widget.searchHintText,
              hintStyle: widget.searchHintTextStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      )
          : null,
      // This is to clear the search value when you close the menu
      onMenuStateChange: widget.isSearchable
          ? (isOpen) {
        if (!isOpen) {
          _textEditingController.clear();
        }
      }
          : null,
    );
  }
}
