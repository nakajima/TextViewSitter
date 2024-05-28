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

	func load(theme: Theme) {
		highlighter.highlightTask?.cancel()

		if theme.fontFamily.name != self.theme.fontFamily.name {
			textView.font = theme.fonts.regular()
		}

		self.theme = theme

		// TODO: This crashes if it happens while the textStorage is laying out. We don't love that.
		textView.typingAttributes = theme.typingAttributes

		highlighter.update(theme: theme, for: textStorage)
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
			let scrollView = NSScrollView()
			scrollView.autohidesScrollers = true
			scrollView.hasVerticalScroller = true
			let max = CGFloat.greatestFiniteMagnitude

			textView.textContainerInset = .init(width: 16, height: 16)
			textView.isRichText = false
			textView.allowsUndo = true
			textView.autoresizingMask = .width

			textView.minSize = NSSize.zero
			textView.maxSize = NSSize(width: max, height: max)

			textView.isVerticallyResizable = true
			textView.isHorizontallyResizable = false
			textView.isRichText = false
			textView.usesFindPanel = true

			scrollView.translatesAutoresizingMaskIntoConstraints = false
			textView.translatesAutoresizingMaskIntoConstraints = false
			view.translatesAutoresizingMaskIntoConstraints = false

			scrollView.documentView = textView
			view.addSubview(scrollView)

			NSLayoutConstraint.activate([
				scrollView.topAnchor.constraint(equalTo: view.topAnchor),
				scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			])

			NSLayoutConstraint.activate([
				//				textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
				textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
				textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			])

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
