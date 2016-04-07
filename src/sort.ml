(**************************************************************************)
(*                                                                        *)
(*  This file is part of OCI-sort (example for OCI tutorial).             *)
(*                                                                        *)
(*  Copyright (C) 2015-2016                                               *)
(*    CEA (Commissariat à l'énergie atomique et aux énergies              *)
(*         alternatives)                                                  *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License as published by the Free Software       *)
(*  Foundation, version 2.1.                                              *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public License version 2.1                 *)
(*  for more details (enclosed in the file licenses/LGPLv2.1).            *)
(*                                                                        *)
(**************************************************************************)


let input_file = Sys.argv.(1)

let arg_seed,arg_max,arg_length =
  let cin = open_in input_file in
  let parse_int () = int_of_string (input_line cin) in
  let arg_seed = parse_int () in
  let arg_max = abs (parse_int ()) in
  let arg_length = abs (parse_int ()) in
  close_in cin;
  arg_seed, arg_max, arg_length

let sum r = Array.fold_left (+) 0 r
let debug r =
  if try Sys.getenv "DEBUG_OCI_SORT" <> "no" with Not_found -> false
  then begin
    Format.printf "[@[";
    Array.iter (Format.printf "%i;@,") r;
    Format.printf "@]]@."
  end

let array =
  Random.init arg_seed;
  Array.init arg_length (fun _ -> Random.int arg_max)

let input_sum = sum array
let () = debug array

let () = Array.sort (fun (x:int) y -> Pervasives.compare x y) array

let sorted_sum = sum array
let () = debug array


let () =
  Format.printf "sum_before: %i\n sum_after: %i\n%!"
    input_sum sorted_sum
