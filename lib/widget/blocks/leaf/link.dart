import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/configs.dart';
import '../../span_node.dart';

///Tag: [MarkdownTag.a]
///
///Link reference definitions, A link reference definition consists of a link label
///link will always be wrapped by other tags, such as [MarkdownTag.p]

class LinkNode extends ElementNode {
  final Map<String, String> attributes;
  final LinkConfig linkConfig;

  LinkNode(this.attributes, this.linkConfig);

  @override
  InlineSpan build() {
    final url = attributes['href'] ?? '';
    return TextSpan(children: List.generate(children.length, (index){
      final child = children[index];
      InlineSpan span = child.build();
      ///FIXME: there must be no children in TextSpan that the [TapGestureRecognizer] will work rightly
      if (span is TextSpan) {
        span = TextSpan(
          text: span.text,
          children: span.children,
          style: span.style,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _onLinkTap(linkConfig, url);
            },
        );
      } else if (span is WidgetSpan) {
        span = WidgetSpan(
            child: GestureDetector(
              child: span.child,
              onTap: () {
                _onLinkTap(linkConfig, url);
              },
            ),
            alignment: span.alignment,
            baseline: span.baseline,
            style: span.style);
      }
      return span;
    }));
  }

  @override
  TextStyle get style => TextStyle(color: linkConfig.color).merge(parentStyle);
}

void _onLinkTap(LinkConfig linkConfig, String url) {
  if (linkConfig.onTap != null) {
    linkConfig.onTap?.call(url);
  } else {
    launchUrl(Uri.parse(url));
  }
}

///config class for link, tag: a
class LinkConfig implements LeafConfig {
  final Color color;
  final ValueCallback<String>? onTap;

  const LinkConfig({this.color = const Color(0xff0969da), this.onTap});

  @nonVirtual
  @override
  String get tag => MarkdownTag.a.name;
}
