import Future

extension Span {
  var startIndex: Int { 0 }
  var endIndex: Int { count }
}

extension RawSpan {
  var startIndex: Int { 0 }
  var endIndex: Int { byteCount }
}
