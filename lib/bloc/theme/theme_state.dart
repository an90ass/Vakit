import 'package:equatable/equatable.dart';
import 'package:vakit/theme/vakit_palette.dart';

class VakitThemeState extends Equatable {
  const VakitThemeState({required this.palette, required this.softness});

  final VakitPalette palette;
  final double softness;

  VakitThemeState copyWith({VakitPalette? palette, double? softness}) {
    return VakitThemeState(
      palette: palette ?? this.palette,
      softness: softness ?? this.softness,
    );
  }

  @override
  List<Object?> get props => [palette.id, softness];
}
