bool isEmpty(dynamic field) {
  return ((field == null) ||
      field == 0 ||
      field.length == 0 ||
      (field == false));
}

dynamic myDateSerializer(dynamic object) {
  if (object is DateTime) {
    return object.toIso8601String();
  }
  return object;
}
