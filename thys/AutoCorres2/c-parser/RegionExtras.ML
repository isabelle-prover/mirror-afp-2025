(*
 * Copyright 2020, Data61, CSIRO (ABN 41 687 119 230)
 * Copyright (c) 2022 Apple Inc. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *)

signature REGION_EXTRAS =
sig
  type 'a wrap
  val bogus : SourcePos.t
  val wrap : 'a * SourcePos.t * SourcePos.t -> 'a wrap
  val unwrap : 'a wrap -> 'a * SourcePos.t * SourcePos.t
  val bogwrap : 'a -> 'a wrap
  val left : 'a wrap -> SourcePos.t
  val right : 'a wrap -> SourcePos.t
  val node : 'a wrap -> 'a
  val apnode : ('a -> 'b) -> 'a wrap -> 'b wrap

end

structure RegionExtras : REGION_EXTRAS =
struct

val bogus = SourcePos.bogus
type 'a wrap = 'a Region.Wrap.t
fun wrap (x,l,r) = Region.Wrap.makeRegion'(x,l,r)
fun bogwrap x = wrap(x,bogus,bogus)
fun left w =
    the (Region.left (Region.Wrap.region w)) handle Option => bogus
fun right w =
    the (Region.right (Region.Wrap.region w))
    handle Option => bogus
val node = Region.Wrap.node
fun unwrap x = (node x, left x, right x)
fun apnode f x_w = let
  val x = node x_w
in
  wrap (f x, left x_w, right x_w)
end

fun merge_regions [] = Region.bogus
  | merge_regions ws =
    let
      val first = hd ws
      val last = hd (rev ws)
    in 
      Region.make {left = left first, right = right last}
    end

end (* struct *)

