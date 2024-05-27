@testable import TextViewSitter
import XCTest

final class TextViewSitterTests: XCTestCase {
	func load(_ sample: String) -> String {
		try! String(
			contentsOf: Bundle.module.url(
				forResource: sample,
				withExtension: "md"
			)!
		)
	}

	override class func setUp() {
		// Don't incur the hit of loading languages in tests
		_ = LanguageProvider.languagesByName
	}

	func testPerformance() async throws {
		let sample = load("Big")
		let storage = NSTextStorage()
		storage.setAttributedString(.init(string: sample))

		let highlighter = Highlighter(
			textStorage: storage,
			theme: .default,
			styles: StyleBuilder.default
		)

		highlighter.parser.load(text: sample)

		let captures = await Benchy.measure("MEASURE captures") {
			try! await highlighter.parser.captures()
		}

		XCTAssertEqual(121_758, captures!.count)
	}
}
