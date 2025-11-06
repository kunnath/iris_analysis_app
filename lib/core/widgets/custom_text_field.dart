import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextFieldType {
  text,
  email,
  password,
  phone,
  number,
  multiline,
  search,
}

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? prefixText;
  final String? suffixText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final TextEditingController? controller;
  final TextFieldType type;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderWidth;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool showCharacterCount;
  final bool autofocus;
  final String? initialValue;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixText,
    this.suffixText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.controller,
    this.type = TextFieldType.text,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.showCharacterCount = false,
    this.autofocus = false,
    this.initialValue,
  });

  // Named constructors for common field types
  const CustomTextField.email({
    super.key,
    this.label = 'Email',
    this.hint = 'Enter your email',
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.required = true,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
  }) : type = TextFieldType.email,
       prefixText = null,
       suffixText = null,
       prefixIcon = Icons.email_outlined,
       suffixIcon = null,
       prefix = null,
       suffix = null,
       obscureText = false,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       textInputAction = TextInputAction.next,
       onTap = null,
       onEditingComplete = null,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       contentPadding = null,
       borderRadius = null,
       fillColor = null,
       borderColor = null,
       focusedBorderColor = null,
       errorBorderColor = null,
       borderWidth = null,
       textStyle = null,
       labelStyle = null,
       hintStyle = null,
       showCharacterCount = false;

  const CustomTextField.password({
    super.key,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.required = true,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
  }) : type = TextFieldType.password,
       prefixText = null,
       suffixText = null,
       prefixIcon = Icons.lock_outlined,
       suffixIcon = null,
       prefix = null,
       suffix = null,
       obscureText = true,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       textInputAction = TextInputAction.done,
       onTap = null,
       onEditingComplete = null,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       contentPadding = null,
       borderRadius = null,
       fillColor = null,
       borderColor = null,
       focusedBorderColor = null,
       errorBorderColor = null,
       borderWidth = null,
       textStyle = null,
       labelStyle = null,
       hintStyle = null,
       showCharacterCount = false;

  const CustomTextField.phone({
    super.key,
    this.label = 'Phone Number',
    this.hint = 'Enter your phone number',
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.required = true,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
  }) : type = TextFieldType.phone,
       prefixText = null,
       suffixText = null,
       prefixIcon = Icons.phone_outlined,
       suffixIcon = null,
       prefix = null,
       suffix = null,
       obscureText = false,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       textInputAction = TextInputAction.done,
       onTap = null,
       onEditingComplete = null,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       contentPadding = null,
       borderRadius = null,
       fillColor = null,
       borderColor = null,
       focusedBorderColor = null,
       errorBorderColor = null,
       borderWidth = null,
       textStyle = null,
       labelStyle = null,
       hintStyle = null,
       showCharacterCount = false;

  const CustomTextField.search({
    super.key,
    this.label,
    this.hint = 'Search...',
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
  }) : type = TextFieldType.search,
       prefixText = null,
       suffixText = null,
       prefixIcon = Icons.search,
       suffixIcon = null,
       prefix = null,
       suffix = null,
       obscureText = false,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       textInputAction = TextInputAction.search,
       onTap = null,
       onEditingComplete = null,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       contentPadding = null,
       borderRadius = null,
       fillColor = null,
       borderColor = null,
       focusedBorderColor = null,
       errorBorderColor = null,
       borderWidth = null,
       textStyle = null,
       labelStyle = null,
       hintStyle = null,
       showCharacterCount = false;

  const CustomTextField.multiline({
    super.key,
    this.label,
    this.hint = 'Enter text...',
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.maxLines = 4,
    this.minLines = 3,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.showCharacterCount = true,
    this.autofocus = false,
    this.initialValue,
  }) : type = TextFieldType.multiline,
       prefixText = null,
       suffixText = null,
       prefixIcon = null,
       suffixIcon = null,
       prefix = null,
       suffix = null,
       obscureText = false,
       textInputAction = TextInputAction.newline,
       onTap = null,
       onEditingComplete = null,
       textCapitalization = TextCapitalization.sentences,
       inputFormatters = null,
       contentPadding = null,
       borderRadius = null,
       fillColor = null,
       borderColor = null,
       focusedBorderColor = null,
       errorBorderColor = null,
       borderWidth = null,
       textStyle = null,
       labelStyle = null,
       hintStyle = null;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _labelAnimation;
  
  bool _obscureText = false;
  bool _hasFocus = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
    _errorText = widget.errorText;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: widget.borderColor ?? Colors.grey.shade300,
      end: widget.focusedBorderColor ?? Theme.of(context).primaryColor,
    ).animate(_animationController);

    _labelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    if (_hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) _buildLabel(),
        _buildTextField(),
        if (widget.helperText != null || _errorText != null || widget.showCharacterCount)
          _buildHelperArea(),
      ],
    );
  }

  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            widget.label!,
            style: widget.labelStyle ?? 
                   Theme.of(context).textTheme.labelMedium?.copyWith(
                     fontWeight: FontWeight.w600,
                   ),
          ),
          if (widget.required)
            Text(
              ' *',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        return TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: _obscureText,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: _getInputFormatters(),
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          onTap: widget.onTap,
          onChanged: _onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          style: widget.textStyle,
          decoration: _buildInputDecoration(),
        );
      },
    );
  }

  Widget _buildHelperArea() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _errorText != null
                ? Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  )
                : widget.helperText != null
                    ? Text(
                        widget.helperText!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
          if (widget.showCharacterCount && widget.maxLength != null)
            Text(
              '${_controller.text.length}/${widget.maxLength}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration() {
    final theme = Theme.of(context);
    final hasError = _errorText != null;
    
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: widget.hintStyle ?? 
                 TextStyle(color: Colors.grey.shade400),
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      prefixIcon: _buildPrefixIcon(),
      suffixIcon: _buildSuffixIcon(),
      prefix: widget.prefix,
      suffix: widget.suffix,
      filled: true,
      fillColor: widget.fillColor ?? 
                (widget.enabled ? Colors.grey.shade50 : Colors.grey.shade100),
      contentPadding: widget.contentPadding ?? 
                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: _buildBorder(Colors.grey.shade300),
      enabledBorder: _buildBorder(widget.borderColor ?? Colors.grey.shade300),
      focusedBorder: _buildBorder(
        hasError 
            ? theme.colorScheme.error 
            : (widget.focusedBorderColor ?? theme.primaryColor),
      ),
      errorBorder: _buildBorder(theme.colorScheme.error),
      focusedErrorBorder: _buildBorder(theme.colorScheme.error),
      disabledBorder: _buildBorder(Colors.grey.shade200),
      counterText: widget.showCharacterCount ? null : '',
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon != null) {
      return Icon(
        widget.prefixIcon,
        color: _hasFocus 
            ? (Theme.of(context).primaryColor) 
            : Colors.grey.shade400,
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == TextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey.shade400,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: _hasFocus 
            ? (Theme.of(context).primaryColor) 
            : Colors.grey.shade400,
      );
    }

    if (widget.type == TextFieldType.search && _controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear, color: Colors.grey),
        onPressed: () {
          _controller.clear();
          widget.onChanged?.call('');
        },
      );
    }

    return null;
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: widget.borderWidth ?? 1.0,
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputFormatters != null) {
      return widget.inputFormatters;
    }

    switch (widget.type) {
      case TextFieldType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
          _PhoneNumberFormatter(),
        ];
      case TextFieldType.number:
        return [
          FilteringTextInputFormatter.digitsOnly,
        ];
      case TextFieldType.email:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
        ];
      default:
        return null;
    }
  }

  void _onChanged(String value) {
    // Clear error when user starts typing
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }

    widget.onChanged?.call(value);

    // Auto-validation for common patterns
    if (widget.type == TextFieldType.email && value.isNotEmpty) {
      _validateEmail(value);
    }
  }

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorText = 'Please enter a valid email address';
      });
    }
  }
}

// Custom formatter for phone numbers
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    if (text.length >= 1) {
      formatted = '(${text.substring(0, text.length > 3 ? 3 : text.length)}';
    }
    if (text.length >= 4) {
      formatted += ') ${text.substring(3, text.length > 6 ? 6 : text.length)}';
    }
    if (text.length >= 7) {
      formatted += '-${text.substring(6, text.length > 10 ? 10 : text.length)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Extension for easy validation
extension CustomTextFieldValidation on CustomTextField {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}

// Utility class for common text field configurations
class TextFieldConfig {
  static const EdgeInsets defaultPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  
  static const BorderRadius defaultBorderRadius = BorderRadius.all(
    Radius.circular(12),
  );
  
  static const Duration animationDuration = Duration(milliseconds: 200);
  
  // Common input formatters
  static final List<TextInputFormatter> phoneFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(15),
    _PhoneNumberFormatter(),
  ];
  
  static final List<TextInputFormatter> numberFormatters = [
    FilteringTextInputFormatter.digitsOnly,
  ];
  
  static final List<TextInputFormatter> emailFormatters = [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
  ];
  
  static final List<TextInputFormatter> nameFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ];
}
