// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:exhaustiveness_prototype/static_type.dart';

import 'space.dart';

/// Calculates the intersection of [left] and [right].
///
/// This is used to tell if two field spaces on a pair of spaces being
/// subtracted have no common values.
Space intersect(Space left, Space right) {
  // The intersection with an empty space is always empty.
  if (left == Space.empty) return Space.empty;
  if (right == Space.empty) return Space.empty;

  // The intersection of a union is the union of the intersections of its arms.
  if (left is UnionSpace) {
    return Space.union(left.arms.map((arm) => intersect(arm, right)).toList());
  }

  if (right is UnionSpace) {
    return Space.union(right.arms.map((arm) => intersect(left, arm)).toList());
  }

  // Otherwise, we're intersecting two [ExtractSpaces].
  return _intersectExtracts(left as ExtractSpace, right as ExtractSpace);
}

/// Returns the interaction of extract spaces [left] and [right].
Space _intersectExtracts(ExtractSpace left, ExtractSpace right) {
  var type = intersectTypes(left.type, right.type);

  // If the types are disjoint, the intersection is empty.
  if (type == null) return Space.empty;

  // Recursively intersect the fields.
  var fieldNames = {...left.fields.keys, ...right.fields.keys}.toList();

  // Sorting isn't needed for correctness, just to make the tests less brittle.
  fieldNames.sort();

  var fields = <String, Space>{};
  for (var name in fieldNames) {
    var field = _intersectFields(left.fields[name], right.fields[name]);

    // If the fields are disjoint, then the entire space will have no values.
    if (field == Space.empty) return Space.empty;
    fields[name] = field;
  }

  return Space(type, fields);
}

Space _intersectFields(Space? left, Space? right) {
  if (left == null) return right!;
  if (right == null) return left;
  return intersect(left, right);
}

/// Returns the intersection of two static types [left] and [right].
///
/// Returns `null` if the intersection is empty.
StaticType? intersectTypes(StaticType left, StaticType right) {
  // If one type is a subtype, the subtype is the intersection.
  if (left.isSubtypeOf(right)) return left;
  if (right.isSubtypeOf(left)) return right;

  // If we allow sealed types to share subtypes, then this will need to be more
  // sophisticated. Here:
  //
  //   (A) (B)
  //   / \ / \
  //  C   D   E
  //
  // The intersection of A and B should be D. Here:
  //
  //  (A)   (B)
  //   | \  / |
  //   |\ \/ /|
  //   | \/\/ |
  //   C D  E F
  //
  // It should be D, E.

  // Unrelated types.
  return null;
}
