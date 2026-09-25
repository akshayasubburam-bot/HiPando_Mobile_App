import 'package:flutter_application/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Hi Pando landing page', (tester) async {
    await tester.pumpWidget(const HiPandoApp());
    await tester.pump();
    expect(find.text('Hi Pando'), findsOneWidget);
    expect(find.textContaining('Find your'), findsOneWidget);
  });
}
