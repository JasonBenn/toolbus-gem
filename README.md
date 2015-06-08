A Feature can take many forms.

["(", rails_uses_activesupport, "||" , rails_uses_jbuilder, ")", "&&", ember_uses_active_model_adapter]

{
  parser: "ruby-2.1.2",  // { "whitquark/parser", "gem", "2.2.0" } ?
  glob: "app**/*.rb",     // if no files match glob when CLI runs, ask if we're at the right root
  find: "includes ActionController::ImplicitRender"
}



TRANSFORM each task object into { loc: [{ line_start: 1, line_end: 5 }, { line_start: 10, line_end: 10 }] } or { loc: [] } // could just be arrays
JOIN any "(", ")" "&&", "||", "true", "false" into a string
IF EVAL string
  // how do i post a completion with multiple matches?
  POST completions, with rule id, username, project id, line_start. eventually will also need a gist id.



Blueprint details

One reserved word:
ANYTHING.

Maybe others are necessary?
ANYTHING_MATCHING("?"). # will cast symbols and strings 
CONDITION. a predicate method. will be tested against all children, considered true if it passes.

Todo:

* Write Toolbus#fetch_features.
* POST /completions correctly, and update the status message.
* Implement SyntaxTree.include?
* Test various SyntaxTree inclusions.
* Fill out README.
* Fix display bug when you invoke toolbus when {toolbus height} > {remaining console height}.
* Add JS support with https://github.com/babel/ruby-babel-transpiler
