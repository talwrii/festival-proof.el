# festival-proof.el

Writing is hard. It is an adage that most of writing is editing.
But the more one edits the more one is likely to introduce mistakes
and the more blind one becomes to these mistakes - since one becomes
used to the text.

This package tries to correct this text-specific learned inattentional blindness
by using another sense: hearing. It reads sentences back to you while proof-reading
saying punctuation out loud to help one detect errors.

This package is a convenience wrapper around the festival library in emacs.

Basic usage:
 * Bind festival-proof-say-sentence to a key and use it to read sentences.
 * You can increase and decrease speed using festival-proof-faster and festival-proof-slower

# Installation

Using [straight](https://github.com/raxod502/straight.el#install-packages) at the following to your `init.el` file. Packages installed with straight can happily coexist those installed with `package.el`.

```
(straight-use-package '(festival-proof :type git :host github :repo "talwrii/festival-proof.el"))
```
