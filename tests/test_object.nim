import unittest, ../msgpack4nim
import typetraits

type G = distinct int
func `==`(a, b: G): bool {.borrow.}

proc pack_type[S](s: S, g: G) =
  echo "Pack G"
  msgpack4nim.pack_type(s, g)

proc unpack_type[S](s: S, g: var G) =
  echo "Unpack G"
  msgpack4nim.unpack_type(s, g)


suite "custom object conversion":

  template validate(t: typed): untyped =
    check(t.pack().unpack(type(t)) == t)

  type A = object
    f1: int
    f2: float
    f3: string

  test "simple object":
    validate(A(f1: 3, f2: -1.0, f3: "foo"))

  type B[T] = object
    f1: T
    f2: bool

  test "generic object":
    validate(B[string](f1: "foo", f2: true))

  type C = distinct A
  proc `==`(a, b: C): bool {.borrow.}

  test "distinct object":
    validate(A(f1: 3).C)

  type D = distinct B[bool]
  proc `==`(a, b: D): bool {.borrow.}

  test "distinct generic object":
    validate(B[bool](f1: true, f2: false).D)

  type E = distinct D
  proc `==`(a, b: E): bool =
    a.D == b.D

  test "distinct object chain":
    validate(B[bool]().D.E)

  type F = D

  test "alias for distinct object":
    validate(B[bool]().F)

  test "custom pack/unpack for distinct type":
    validate(3.G)

  # TODO: Test looking for pack/unpack overloads on the distinct type