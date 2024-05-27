// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "TextViewSitter",
	platforms: [
		.macOS(.v14),
		.iOS(.v17),
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
		.package(url: "https://github.com/ChimeHQ/Rearrange", branch: "main"),
		.package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", branch: "main"),

		// Tree sitter gramamrs
		.package(url: "https://github.com/tree-sitter/tree-sitter-html", branch: "master"),
		.package(url: "https://github.com/tree-sitter-grammars/tree-sitter-markdown", branch: "split_parser"),
		.package(url: "https://github.com/alex-pinkus/tree-sitter-swift", branch: "with-generated-files"),
		.package(url: "https://github.com/tree-sitter-grammars/tree-sitter-yaml", branch: "master"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "TextViewSitter",
			dependencies: [
				"NSUI",
				"Rearrange",
				.product(name: "SwiftTreeSitter", package: "SwiftTreeSitter"),
				.product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
				.product(name: "TreeSitterHTML", package: "tree-sitter-html"),
				.product(name: "TreeSitterSwift", package: "tree-sitter-swift"),
				.product(name: "TreeSitterYAML", package: "tree-sitter-yaml"),
			],
			resources: [
				.copy("Resources/Markdown"),
				.copy("Resources/MarkdownInline"),
				.copy("Resources/HTML"),
				.copy("Resources/Swift"),
				.copy("Resources/YAML"),
				//				.copy("Resources/MarkdownQueries/injections.scm"),
			]
		),
		.testTarget(
			name: "TextViewSitterTests",
			dependencies: ["TextViewSitter"],
			resources: [
				.process("Resources/Big.md"),
			]
		),
	]
)

let swiftSettings: [SwiftSetting] = [
	.enableExperimentalFeature("StrictConcurrency"),
	.enableUpcomingFeature("DisableOutwardActorInference"),
]

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: swiftSettings)
	target.swiftSettings = settings
}
