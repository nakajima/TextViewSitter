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

public class TextViewSitterController: NSUIViewController {
	public typealias ChangeCallback = (String) -> Void

	let highlighter: Highlighter

	// This is the TextView. I'm not sure what else to say about it.
	var textView: TextView

	var textStorage: NSTextStorage

	// What's it look like tho
	var theme: Theme

	/// Called when the text changes
	public var textChangeCallback: ChangeCallback?

	public init(text: String, styles: HighlighterStyleContainer, theme: Theme = .default, textChangeCallback: ChangeCallback?) {
		self.textView = TextView()
		self.textChangeCallback = textChangeCallback

		// TODO: Make this nicer
		self.textStorage = textView.nsuiTextStorage!
		self.theme = theme
		self.highlighter = Highlighter(textStorage: textStorage, theme: theme, styles: styles)

		super.init(nibName: nil, bundle: nil)
		textView.delegate = self

		// Do platform specific setup and assign it to our view
		setupTextView()

		// Setup initial styles
		textView.typingAttributes = theme.typingAttributes

		load(text: text)

		NotificationCenter.default.addObserver(forName: NSTextStorage.didProcessEditingNotification, object: textStorage, queue: .main) { _ in
			//			textChangeCallback?(self.textStorage.string)
		}
	}

	func load(text: String) {
		textStorage.beginEditing()
		textStorage.setAttributedString(.init(string: text))
		textStorage.addAttributes(theme.typingAttributes, range: NSRange(textStorage: textStorage))
		textStorage.endEditing()
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

			textView.minSize = NSSize.zero
			textView.maxSize = NSSize(width: max, height: max)
			textView.isVerticallyResizable = true
			textView.isHorizontallyResizable = true
			textView.isRichText = false
			textView.usesFindPanel = true
			scrollView.documentView = textView
			view = scrollView
		#else
			textView.isFindInteractionEnabled = true
			view = textView
		#endif
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension TextViewSitterController: NSUITextViewDelegate {
	public func textViewDidChangeSelection(_: Notification) {
		guard let selection = textView.selectedRanges.first else {
			return
		}

		let highlights = highlighter.highlights(at: selection.rangeValue.location)

		if !highlights.isEmpty {
			print("highlights for selection: \(highlights)")
		}
	}
}
