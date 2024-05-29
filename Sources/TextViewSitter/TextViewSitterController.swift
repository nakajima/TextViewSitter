//
//  TextViewSitterController.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI
import TextFormation
import TextStory

@MainActor public class TextViewSitterController<Model: TextViewSitterTextModel>: NSUIViewController, NSUITextViewDelegate, NSTextStorageDelegate {
	public typealias ChangeCallback = (String) -> Void
	public typealias CaretCallback = (CaretState) -> Void

	var caretState: CaretState?

	let textMutationApplier = TextViewFilterApplier(
		filters: [
			StandardOpenPairFilter(open: "{", close: "}"),
			NewlineProcessingFilter(),
		],
		providers: WhitespaceProviders(
			leadingWhitespace: TextualIndenter().substitionProvider(
				indentationUnit: "\t",
				width: 1
			),
			trailingWhitespace: { _, _ in "" }
		)
	)

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

		setupTextView()

		// Setup initial styles
		textView.typingAttributes = theme.typingAttributes

		load(model: model)
	}

	// Try to size things properly according to character width. This gets called
	// before anything is laid out so sometimes we need to estimate the container
	// width by just looking at the window size. None of this feels ideal, there's
	// probably a better place to hook into tbh.
	// TODO: maybe move some stuff out of setupTextView into the so we can use layoutSubviews
	func sizeTextView() {
		#if os(macOS)
			let scrollViewWidth = scrollView.contentView.frame.width
			let containerWidth = scrollViewWidth == 0 ? NSApplication.shared.windows.first!.frame.width : scrollViewWidth
			let insetWidth = (containerWidth - theme.editorWidth) / 2 - theme.letterWidth * 1.5

			textView.textContainerInset = .init(
				width: max(theme.letterWidth, insetWidth),
				height: theme.letterWidth * 2
			)
		#else
			let window = UIApplication
				.shared
				.connectedScenes
				.compactMap { ($0 as? UIWindowScene)?.keyWindow }
				.last
			let windowWidth = window?.bounds.width ?? 0
			let containerWidth = view.frame.width == 0 ? windowWidth : view.frame.width
			let insetWidth = (containerWidth - theme.editorWidth) / 2 - theme.letterWidth

			// If we're on a small screen, don't bother with horizontal padding
			let horizontal: CGFloat = if windowWidth < 500 {
				0.0
			} else {
				max(theme.letterWidth, insetWidth)
			}

			textView.textContainerInset = .init(
				top: theme.letterWidth * 2,
				left: horizontal,
				bottom: theme.letterWidth * 2,
				right: horizontal
			)
		#endif
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
		highlighter.load(text: model.text) { attributeString in
			self.textStorage.beginEditing()
			self.textStorage.setAttributedString(attributeString)
			self.textStorage.endEditing()
		}

		DispatchQueue.main.async {
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

			NotificationCenter.default.addObserver(
				forName: NSWindow.didResizeNotification,
				object: nil,
				queue: .main
			) { _ in
				MainActor.assumeIsolated {
					self.sizeTextView()
				}
			}

			view = scrollView
		#elseif !os(tvOS)
			textView.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
			textView.isFindInteractionEnabled = true
			textView.smartDashesType = .no
			view = textView
		#endif

		sizeTextView()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	#if os(macOS)
		public func textViewDidChangeSelection(_: Notification) {
			guard let state = caretState() else {
				return
			}

			DispatchQueue.main.async {
				self.caretChangeCallback?(state)
			}
		}

		public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
			guard let text = replacementString else {
				return true
			}

			guard let caretState, caretState.allowsAutoIndentation else {
				return true
			}

			return textMutationApplier.textView(
				textView,
				shouldChangeTextInRange: affectedCharRange,
				replacementString: replacementString
			)
		}
	#else
		public func textViewDidChangeSelection(_: UITextView) {
			updateCaretState()

			guard let caretState else {
				return
			}

			if caretState.allowsAutoFormatting == true {
				textView.autocorrectionType = .default
				textView.autocapitalizationType = .sentences
				textView.spellCheckingType = .default
				textView.smartQuotesType = .default
				textView.smartDashesType = .no
				textView.smartInsertDeleteType = .default
			} else {
				print("disabling auto formatting")
				textView.autocorrectionType = .no
				textView.autocapitalizationType = .none
				textView.spellCheckingType = .no
				textView.smartQuotesType = .no
				textView.smartDashesType = .no
				textView.smartInsertDeleteType = .no
			}

			DispatchQueue.main.async {
				self.caretChangeCallback?(caretState)
			}
		}

		public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
			if let action = ReplacerResolver(
				trigger: .characters(text),
				selection: range,
				textView: self.textView
			).result() {
				self.textView.performReplacement(action, selection: self.textView.selectedRange)
				return false
			}

			return textMutationApplier.textView(
				textView,
				shouldChangeTextIn: range,
				replacementText: text
			)
		}
	#endif

	@MainActor public func updateCaretState() {
		guard let selection = MainActor.assumeIsolated({
			textView.selectedRanges
		}).first else {
			return
		}

		let highlights = highlighter.highlights(at: selection.rangeValue.location)

		var allowsAutoFormatting = true
		var allowsAutoIndentation = false

		for highlight in highlights {
			if highlight.nodeType == "fenced_code_block" {
				allowsAutoFormatting = false
				allowsAutoIndentation = true
			}
		}

		caretState = CaretState(
			selectedRange: selection.rangeValue,
			highlights: highlights,
			allowsAutoIndentation: allowsAutoIndentation,
			allowsAutoFormatting: allowsAutoFormatting
		)
	}

	public nonisolated(unsafe) func textStorage(_: NSTextStorage, willProcessEditing _: NSTextStorage.EditActions, range _: NSRange, changeInLength _: Int) {}

	public nonisolated(unsafe) func textStorage(_ storage: NSTextStorage, didProcessEditing actions: NSTextStorage.EditActions, range _: NSRange, changeInLength _: Int) {
		guard actions.contains(.editedCharacters) else {
			return
		}

		MainActor.assumeIsolated {
			model.didChange(text: textStorage.string)
			highlighter.highlight(storage)
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
