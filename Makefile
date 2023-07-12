coverage:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html

brunner:
	dart run build_runner build --delete-conflicting-outputs