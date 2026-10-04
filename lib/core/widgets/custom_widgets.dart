import 'package:englishfun/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(18),
          child: child,
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : (icon == null ? const SizedBox.shrink() : Icon(icon)),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: textColor ?? Colors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fillColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: fillColor ?? AppColors.primary,
      textColor: Colors.white,
    );
  }
}

class CustomCard extends AppCard {
  const CustomCard({
    super.key,
    this.backgroundColor,
    this.borderRadius,
    super.onTap,
    super.padding,
    required super.child,
  });

  final Color? backgroundColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: key,
      onTap: onTap,
      padding: padding,
      child: child,
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hintText: hintText,
      controller: controller ?? TextEditingController(),
      keyboardType: keyboardType,
      obscureText: obscureText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  const AchievementCard({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.progress,
    this.label = '',
    this.progressColor,
  });

  final double progress;
  final String label;
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          minHeight: 8,
          backgroundColor: const Color(0xFFE5E7EB),
          valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.label,
    required this.current,
    required this.total,
    required this.color,
  });

  final String label;
  final int current;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ProgressBar(progress: total == 0 ? 0 : current / total, label: label, progressColor: color);
  }
}

class WordChip extends StatelessWidget {
  const WordChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.backgroundColor,
    this.selectedColor,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (selectedColor ?? AppColors.primary) : (backgroundColor ?? const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class VocabularyCard extends StatelessWidget {
  const VocabularyCard({
    super.key,
    required this.word,
    required this.onTap,
    this.isFavorite = false,
    this.onFavorite,
  });

  final String word;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              word,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: onFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardWidget extends StatelessWidget {
  const FlashcardWidget({
    super.key,
    required this.word,
    required this.meaning,
    required this.example,
    required this.isFront,
    required this.onTap,
  });

  final String word;
  final String meaning;
  final String example;
  final bool isFront;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isFront ? AppColors.primary : const Color(0xFFFDE68A);
    final textColor = isFront ? Colors.white : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        width: double.infinity,
        height: 260,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isFront ? word : meaning,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              if (!isFront)
                Text(
                  'Example: $example',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizOption extends StatelessWidget {
  const QuizOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect
        ? Colors.green
        : isSelected
            ? Colors.red
            : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.08),
        ),
        child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onAction,
    this.actionLabel,
  });

  final String icon;
  final String title;
  final String description;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 24),
            RoundedButton(label: actionLabel!, onPressed: onAction!),
          ],
        ],
      ),
    );
  }
}
