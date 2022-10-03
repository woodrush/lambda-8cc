(load "./lambdacraft.cl")
(load "./blc-numbers.cl")
(load "./blc-clamb-wrapper.cl")
(load "./usage.cl")


(defrec-lazy append (l1 l2)
  (typematch-nil-cons l1 (car-l1 cdr-l1)
    ;; nil case
    l2
    ;; cons case
    (cons car-l1 (append cdr-l1 l2))))

(defmacro-lazy b0 (x) `(cons t ,x))
(defmacro-lazy b1 (x) `(cons nil ,x))


(defun-lazy istrue (expr)
  (expr (lambda (p q) t) (lambda (x) x) (lambda (x) x) nil))

(defrec-lazy sanitize-char (c cont)
  (typematch-nil-cons c (b bit-cdr)
    ;; nil case
    (cont nil)
    ;; cons case
    (do
      (<- (bit-cdr) (sanitize-char bit-cdr))
      (if b
        (cont (cons t bit-cdr))
        (cont (cons nil bit-cdr))))))

(defrec-lazy sanitize-str (s cont)
  (typematch-nil-cons s (c cdr-s)
    ;; nil case
    (cont nil)
    ;; cons case
    (do
      (<- (c) (sanitize-char c))
      (<- (str) (sanitize-str cdr-s))
      (cont (cons c str)))))

(defun-lazy iscons3 (expr)
  (expr
    (lambda (a b c) (lambda (x) (if (isnil x) nil (lambda (x) t))))
    (cons (lambda (x) x) nil)
    nil))

(defrec-lazy string-concatenator (curstr x)
  (cond
    ((isnil x)
      curstr)
    (t
      (string-concatenator (cons x curstr)))))

(def-lazy usage
  (do
    (let* t t)
    (let* nil nil)
    (let* alphabet-prefix-t alphabet-prefix-t)
    (let* alphabet-prefix-nil alphabet-prefix-nil)
    (let* p-t-nil p-t-nil)
    (let* p-t-t p-t-t)
    (let* p-nil-nil p-nil-nil)
    (let* p-nil-t p-nil-t)
    usage-base))

(defmacro def-main ()
  `(defun-lazy main (eightcc elc maybe-stdin)
    (do
      (let* "\\n"    (do (b0) (b0) (b0) (b0) (b1) (b0) (b1) (b0) nil))
      (let* "6"      (do (b0) (b0) (b1) (b1) (b0) (b1) (b1) (b0) nil))
      (let* "8"      (do (b0) (b0) (b1) (b1) (b1) (b0) (b0) (b0) nil))
      (let* "x"      (do (b0) (b1) (b1) (b1) (b1) (b0) (b0) (b0) nil))
      (let* "y"      (do (b0) (b1) (b1) (b1) (b1) (b0) (b0) (b1) nil))
      (let* "z"      (do (b0) (b1) (b1) (b1) (b1) (b0) (b1) (b0) nil))
      (let* "m"      (do (b0) (b1) (b1) (b0) (b1) (b1) (b0) (b1) nil))
      (let* "c"      (do (b0) (b1) (b1) (b0) (b0) (b0) (b1) (b1) nil))
      (let* "b"      (do (b0) (b1) (b1) (b0) (b0) (b0) (b1) (b0) nil))
      (let* "a"      (do (b0) (b1) (b1) (b0) (b0) (b0) (b0) (b1) nil))
      (let* "l"      (do (b0) (b1) (b1) (b0) (b1) (b1) (b0) (b0) nil))
      (let* opt-x86    (list "x" "8" "6" "\\n"))
      (let* opt-lam    (list "l" "a" "m" "\\n"))
      (let* opt-blc    (list "b" "l" "c" "\\n"))
      (let* opt-lazy   (list "l" "a" "z" "y" "\\n"))
      (let* usage usage)
      (if-then-return (iscons3 maybe-stdin)
        (lambda (stdin)
          (do
            ,@(cond
              ((boundp 'compile-lazyk)
                '((let* stdin (lazykstr-to-blcstr stdin))))
              (t
                nil))
            (if-then-return (isnil stdin)
              usage)
            (<- (opt-input opt-output _) (maybe-stdin))
            (let* input-to-eir (opt-input eightcc (lambda (x) x)))
            (let* opt (opt-output opt-x86 opt-lam opt-blc opt-lazy nil))
            (let* eir-to-out (if (isnil opt) (lambda (x) x) (lambda (s) (elc (append opt s)))))
            (eir-to-out (input-to-eir stdin)))))
      (if-then-return (isnil maybe-stdin)
        usage)
      (elc (append opt-x86 (eightcc
        ,(cond
          ((boundp 'compile-lazyk)
            '(lazykstr-to-blcstr maybe-stdin))
          (t
            'maybe-stdin))))))))

(def-main)

(cond
  ((boundp 'compile-lazyk)
    (format t (compile-to-lam-lazy (blcstr-to-lazykstr main))))
  (t
    (format t (compile-to-lam-lazy main))))
