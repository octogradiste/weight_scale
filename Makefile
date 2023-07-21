.PHONY: coverage brunner doc

coverage:
	flutter test --coverage
	rm -r coverage/html
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html

brunner:
	dart run build_runner build --delete-conflicting-outputs

doc:
	dart doc
	open doc/api/index.html