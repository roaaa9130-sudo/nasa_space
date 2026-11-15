import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa_space_3d/main.dart';

void main() {
  testWidgets('NASA 3D Space app loads main screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NasaSpaceApp(),
      ),
    );

    expect(find.byType(NasaSpaceApp), findsOneWidget);
  });
}
