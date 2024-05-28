//
//  TextViewSitterController.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI

#if os(macOS)
	typealias NSUITextViewDelegate = NSTextViewDelegate
#else
	typealias NSUITextViewDelegate = UITextViewDelegate
#endif

@MainActor public class TextViewSitterController<Model: TextViewSitterTextModel>: NSUIViewController, NSUITextViewDelegate, NSTextStorageDelegate {
	public typealias ChangeCallback = (String) -> Void
	public typealias CaretCallback = (CaretState) -> Void

	let highlighter: Highlighter

	var model: Model

	// This is the TextView. I'm not sure what else to say about it.
	var textView: TextView

	var textStorage: NSTextStorage

	#if os(macOS)
		let scrollView = NSScrollView()
	#endif

	// What's it look like tho
	var theme: Theme

	/// Called when the highlights under the cursor changes
	public var caretChangeCallback: CaretCallback?

	public init(
		model: Model,
		theme: Theme,
		caretChangeCallback: CaretCallback?
	) {
		self.model = model

		self.textView = TextView()
		self.caretChangeCallback = caretChangeCallback

		// TODO: Make this nicer
		self.textStorage = textView.nsuiTextStorage!
		self.theme = theme
		self.highlighter = Highlighter()

		super.init(nibName: nil, bundle: nil)
		textView.delegate = self
		textStorage.delegate = self

		// Do platform specific setup and assign it to our view
		setupTextView()

		// Setup initial styles
		textView.typingAttributes = theme.typingAttributes

		load(model: model)
		load(theme: theme)
	}

	func sizeTextView() {
		let insetWidth = (scrollView.contentView.frame.width - theme.editorWidth) / 2 - theme.letterWidth * 1.5
		textView.textContainerInset = .init(
			width: max(theme.letterWidth, insetWidth),
			height: theme.letterWidth * 2
		)
	}

	func load(theme: Theme) {
		highlighter.highlightTask?.cancel()

		if theme.fontFamily.name != self.theme.fontFamily.name {
			textView.font = theme.fonts.regular()
		}

		self.theme = theme

		// TODO: This crashes if it happens while the textStorage is laying out. We don't love that.
		textView.typingAttributes = theme.typingAttributes

		highlighter.update(theme: theme, for: textStorage)

		sizeTextView()
	}

	func load(model: Model) {
		highlighter.highlightTask?.cancel()

		self.model = model

		textStorage.beginEditing()
		textStorage.setAttributedString(.init(string: model.text))
		textStorage.addAttributes(theme.typingAttributes, range: NSRange(textStorage: textStorage))
		textStorage.endEditing()

		DispatchQueue.main.async {
			self.highlighter.highlight(self.textStorage)
			self.focus()
		}
	}

	func focus() {
		#if os(macOS)
			textView.window?.makeFirstResponder(self)
		#else
			textView.becomeFirstResponder()
		#endif
	}

	func setupTextView() {
		// TODO: this was causing jumpiness when editing? i dunno, look at it.
		textView.nsuiLayoutManager?.allowsNonContiguousLayout = false

		#if os(macOS) && !targetEnvironment(macCatalyst)
			scrollView.autohidesScrollers = true
			scrollView.hasVerticalScroller = true
			scrollView.backgroundColor = .green
			scrollView.autoresizesSubviews = false

			textView.isRichText = false
			textView.allowsUndo = true
			textView.isVerticallyResizable = true
			textView.isHorizontallyResizable = true
			textView.autoresizingMask = [.width]
			textView.isRichText = false
			textView.usesFindPanel = true
			scrollView.documentView = textView
			view = scrollView

			DispatchQueue.main.async {
				self.sizeTextView()
			}
		#elseif !os(tvOS)
			textView.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
			textView.isFindInteractionEnabled = true
			view = textView
		#endif
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	#if os(macOS)
		public func textViewDidChangeSelection(_: Notification) {
			guard let selection = textView.selectedRanges.first else {
				return
			}

			let highlights = highlighter.highlights(at: selection.rangeValue.location)

			DispatchQueue.main.async {
				self.caretChangeCallback?(CaretState(position: selection.rangeValue.location, highlights: highlights))
			}
		}
	#else
		public func textViewDidChangeSelection(_ textView: UITextView) {
			guard let selection = textView.selectedRanges.first else {
				return
			}

			let highlights = highlighter.highlights(at: selection.rangeValue.location)

			DispatchQueue.main.async {
				self.caretChangeCallback?(CaretState(position: selection.rangeValue.location, highlights: highlights))
			}
		}
	#endif

	public nonisolated(unsafe) func textStorage(_: NSTextStorage, willProcessEditing _: NSTextStorage.EditActions, range _: NSRange, changeInLength _: Int) {}

	public nonisolated(unsafe) func textStorage(_: NSTextStorage, didProcessEditing actions: NSTextStorage.EditActions, range _: NSRange, changeInLength _: Int) {
		guard actions.contains(.editedCharacters) else {
			return
		}

		MainActor.assumeIsolated {
			model.didChange(text: textStorage.string)

			// TODO: this is a bit clumsy
			highlighter.highlights(for: textStorage) { _ in
				self.highlighter.applyStyles(in: self.textStorage)
			}
		}
	}
}

#if DEBUG
	final class PreviewTextModel: Equatable, TextViewSitterTextModel {
		static func == (lhs: PreviewTextModel, rhs: PreviewTextModel) -> Bool {
			lhs.text == rhs.text
		}

		var text: String = """
		Previously on patstechweblog: I was flailing my way through Swift macros in order inspect my model's properties. These [macros let me create column definitions](https://github.com/nakajima/ServerData.swift/blob/main/Sources/ServerDataMacros/ModelMacro.swift) that look like this:

		```swift
		public struct ColumnDefinition: Sendable {
		public var name: String
		```

		Previously on patstechweblog: I was flailing my way through Swift macros in order inspect my model's properties. These [macros let me create column definitions](https://github.com/nakajima/ServerData.swift/blob/main/Sources/ServerDataMacros/ModelMacro.swift) that look like this:

		```swift
		public struct ColumnDefinition: Sendable {
		public var name: String
		```

		Previously on patstechweblog: I was flailing my way through Swift macros in order inspect my model's properties. These [macros let me create column definitions](https://github.com/nakajima/ServerData.swift/blob/main/Sources/ServerDataMacros/ModelMacro.swift) that look like this:

		```swift
		public struct ColumnDefinition: Sendable {
		public var name: String
		```
		"""

		func didChange(text: String) {
			self.text = text
		}
	}

	#Preview {
		TextViewSitterController(model: PreviewTextModel(), theme: .default, caretChangeCallback: nil)
	}
#endif
