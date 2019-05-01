;;; festival-proof.el --- Proof read in emacs by having your computer say your text.

;; Copyright (C) 2019 Tal Wrii
;;
;; Author: Tal Wrii <talwrii@gmail.com>
;; Version: 0.0.1
;; Keywords:
;; URL: http://github.com/talwrii/festival-proof
;; Package-Requires: ((s "0") (festival "0") (dash "0"))
;;
;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Writing is hard. It is an adage that most of writing is editing.
;; But the more one edits the more one is likely to introduce mistakes
;; and the more blind one becomes to these mistakes - since one becomes
;; used to the text.

;; This package tries to correct this text-specific learned inattentional blindness
;; by using another on of your senses: hearing. It reads sentences back to you while proof-reading
;; saying punctuation out loud to help one detect errors.

;; This package is a convenience wrapper around the festival library in Emacs.

;; Basic usage:
;;  * Bind festival-proof-say-sentence to a key and use it to read sentences.
;;  * You can increase and decrease speed using festival-proof-faster and festival-proof-slower

;;; Code:

(defvar festival-proof-duration 1.0 "How slowly festival should play.")

(defun festival-proof-say-sentence ()
  "Read the current sentence."
  (interactive)
  (festival-proof-say (thing-at-point 'sentence)))


(defun festival-proof-say-region ()
  "Read the current selected sentence."
  (interactive)
  (festival-proof-scale-speed 1.0)
  (festival-proof-say
   (buffer-substring-no-properties (point) (mark))))

(defun festival-proof-say-possessive (string)
  "Convert possessives in STRING to text that aids proof reading when read out loud."
  (festival-proof-possessive-non-apostrophe
  (s-join ""
          (list
           (s-join ""
           (mapcar
            (lambda (k)
              (let* (
                     (beginning (butlast (s-split " " k) ) )
                     (last-word (car (last (s-split " " k))))
                     (apostrophe-function (festival-proof-apostrophe-es-function last-word)))
                (s-join " "
                        (append
                         beginning
                         (list apostrophe-function
                               (s-concat last-word "'s")) ))))
            (butlast (s-split "'s" string))) )
           (car (last (s-split "'s" string))   )))))

(defun festival-proof-possessive-non-apostrophe (string)
  "Distinguish contractions from possessives in STRING."
  (-reduce-from
   (lambda (s k)
     (replace-regexp-in-string (car k) (cadr k) s))
   string
   (list
    (list "\\blet's\\b" "CONTRACTION Let's")
    (list "\\bwe're\\b" "CONTRACTION we're")
    (list "\\bits\\b" "POSSESSIVE its")
    (list "\\btheir\\b" "POSSESSIVE their")
    (list "\\bthere\\b" "LOCATION EXISTENTIAL there")
    (list "\\bthey're\\b" "CONTRACTION they're"))))

(defun festival-proof-apostrophe-es-function (word)
  "Return the function of WORD, which has an apostrophe."
  (cond
   ((member (downcase word) (list "it"))
    "SUBJECT VERB")
   (t "POSSESSIVE")))


(defun festival-proof-say (text)
  "Read the TEXT with festival in a way suitable for proof reading."
  (festival-stop)
  (festival-start)

  (festival-proof-scale-speed 1.0)
  (festival-say (festival-proof-say-possessive (festival-proof-say-punctuation (festival-proof-render text)))))

(defun festival-proof-render (text)
  "Render TEXT into plain text suitable for proof reading."
  (cond
   ((equal major-mode  'markdown-mode) (my-strip-markdown text))
   (t text)))

(defun festival-proof-line ()
  "Reading the current line for proof reading."
  (interactive)
  (festival-proof-say (substring-no-properties (thing-at-point 'line))))

(defun festival-proof-scale-speed (scale)
  "Multiple the current read back speed by SCALE."
  (interactive)
  (setq festival-proof-duration (* festival-proof-duration scale) )
  (message "%.1f" (/ 1 festival-proof-duration) )
  (festival-proof-send-string (format "(Parameter.set 'Duration_Stretch %.3f)" festival-proof-duration)))

(defun festival-proof-send-string (string)
  "Send a raw string, STRING, to the festival process."
  (interactive)
  (message "Sending: %S" string)
  (process-send-string festival-process string))

(defun festival-proof-faster ()
  "Speed-up  the read-back speed of festival-proof."
  (interactive)
  (festival-proof-scale-speed 0.9)
  (festival-proof-say "faster"))

(defun festival-proof-slower ()
  "Slow-down the read-back speed of festival-proof."
  (interactive)
  (festival-proof-scale-speed  1.1)
  (festival-proof-say "slower"))

(defun festival-proof-say-punctuation (string)
  "Replace punctuation with words that are pronounced out loud in STRING."
  (s-replace "-" " HYPHEN  "
  (s-replace ":)" " SMILEY  "
  (s-replace "\"" " DOUBLE QUOTE  "
  (s-replace ":" " COLON  "
  (s-replace "`" " BACKTICKS  "
  (s-replace ")" " CLOSE BRACKET "
  (s-replace "(" " OPEN BRACKET "
             (s-replace "?" " QUESTION " (s-replace ";" " SEMICOLON " (s-replace "," " COMMA " (s-replace "." " PERIOD " string))))))))))))

(provide 'festival-proof)
;;; festival-proof.el ends here

