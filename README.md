# DFun

DFun is Delphi library to support functional programming style.
It is work in progress.

Currently it contains these types:
* List
* Maybe
* Either
* Pair
* Null

## List
Singly-linked immutable list.

### Construction
```delphi
Xs := List.Cons<Integer>(1, List<Integer>.Empty);
Ys := List.FromArray<Integer>([1, 2, 3]);
```

## Maybe
Optional value. It contains either `Nothing` or `Just` the value.

## Either
A coproduct type, typically represents a result of and operation.
It contains either the left side (usually an error value) or the right side (the actual value).

## Pair
A product type, an ordered pair.

## Null
An unit type, represents a type with single value.
"Unit" cannot be used as a name, because it's a Delphi keyword.
