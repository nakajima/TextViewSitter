// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "TextViewSitter",
	platforms: [
		.macOS(.v14),
		.iOS(.v17)
	],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "TextViewSitter",
			targets: ["TextViewSitter"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/mattmassicotte/NSUI", branch: "main"),
		.package(url: "https://github.com/ChimeHQ/Glyph", branch: "main"),
		.package(url: "https://github.com/tree-sitter/tree-sitter", .upToNextMinor(from: "0.20.9")),
		.package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", branch: "main"),
		.package(url: "https://github.com/ChimeHQ/Rearrange", branch: "main"),

		// Tree sitter gramamrs
		.package(url: "https://github.com/tree-sitter/tree-sitter-html", branch: "master"),
		.package(url: "https://github.com/nakajima/tree-sitter-markdown", branch: "split_parser"),
		.package(url: "https://github.com/alex-pinkus/tree-sitter-swift", branch: "with-generated-files"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "TextViewSitter",
			dependencies: [
				"NSUI",
				"SwiftTreeSitter",
				"Rearrange",
				.product(name: "SwiftTreeSitter", package: "SwiftTreeSitter"),
				.product(name: "TreeSitter", package: "tree-sitter"),
				.product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
				.product(name: "TreeSitterHTML", package: "tree-sitter-html"),
				.product(name: "TreeSitterSwift", package: "tree-sitter-swift"),
			],
			resources: [
				.copy("Resources/Markdown"),
				.copy("Resources/MarkdownInline"),
				.copy("Resources/HTML"),
				.copy("Resources/Swift"),
				//				.copy("Resources/MarkdownQueries/injections.scm"),
			]
		),
		.testTarget(
			name: "TextViewSitterTests",
			dependencies: ["TextViewSitter"]
		),
	]
)
