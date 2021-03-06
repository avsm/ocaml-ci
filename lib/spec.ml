module Selection = Ocaml_ci_api.Worker.Selection

type opam_files = string list [@@deriving to_yojson, ord]

type ty = [
  | `Opam of [ `Build | `Lint of [ `Doc ]] * Selection.t * opam_files
  | `Opam_fmt of Analyse_ocamlformat.source option
  | `Duniverse
] [@@deriving to_yojson, ord]

type t = {
  label : string;
  variant : string;
  ty : ty;
} [@@deriving ord]

let opam ~label ~selection ~analysis op =
  let variant = selection.Selection.id in
  let ty =
    match op with
    | `Build | `Lint `Doc as x -> `Opam (x, selection, Analyse.Analysis.opam_files analysis)
    | `Lint `Fmt -> `Opam_fmt (Analyse.Analysis.ocamlformat_source analysis)
  in
  { label; variant; ty }

let duniverse ~label ~variant =
  { label; variant; ty = `Duniverse }

let pp f t = Fmt.string f t.label

let label t = t.label

let pp_summary f = function
  | `Opam (`Build, _, _) -> Fmt.string f "Opam project build"
  | `Opam (`Lint `Doc, _, _) -> Fmt.string f "Opam project lint documentation"
  | `Opam_fmt v -> Fmt.pf f "ocamlformat version: %a"
                     Fmt.(option ~none:(unit "none") Analyse_ocamlformat.pp_source) v
  | `Duniverse -> Fmt.string f "Duniverse build"
