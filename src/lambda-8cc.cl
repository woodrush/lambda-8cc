(load "./lambdacraft.cl")


(defrec-lazy =-bit (n m)
  (typematch-nil-cons n (car-n cdr-n)
    ;; nil case
    t
    ;; cons case
    (do
      (<- (car-m cdr-m) (m))
      (if-then-return (xnor car-n car-m)
        (=-bit cdr-n cdr-m))
      nil)))

(defrec-lazy beginswith (s1 s2)
  (typematch-nil-cons s1 (car-s1 cdr-s1)
    ;; nil case
    t
    ;; cons case
    (typematch-nil-cons s2 (car-s2 cdr-s2)
      ;; nil case
      nil
      ;; cons case
      (if (=-bit car-s1 car-s2)
        (beginswith cdr-s1 cdr-s2)
        nil))))

(defrec-lazy append (l1 l2)
  (typematch-nil-cons l1 (car-l1 cdr-l1)
    ;; nil case
    l2
    ;; cons case
    (cons car-l1 (append cdr-l1 l2))))

(defmacro-lazy b0 (x) `(cons t ,x))
(defmacro-lazy b1 (x) `(cons nil ,x))

(defun-lazy main (8cc elc stdin)
  (do
    (let* "\\n"    (do (b0) (b0) (b0) (b0) (b1) (b0) (b1) (b0) nil))
    (let* "6"      (do (b0) (b0) (b1) (b1) (b0) (b1) (b1) (b0) nil))
    (let* "8"      (do (b0) (b0) (b1) (b1) (b1) (b0) (b0) (b0) nil))
    (let* "x"      (do (b0) (b1) (b1) (b1) (b1) (b0) (b0) (b0) nil))
    (let* "y"      (do (b0) (b1) (b1) (b1) (b1) (b0) (b0) (b1) nil))
    (let* "z"      (do (b0) (b1) (b1) (b1) (b1) (b0) (b1) (b0) nil))
    (let* "m"      (do (b0) (b1) (b1) (b0) (b1) (b1) (b0) (b1) nil))
    (let* "a"      (do (b0) (b1) (b1) (b0) (b0) (b0) (b0) (b1) nil))
    (let* "l"      (do (b0) (b1) (b1) (b0) (b1) (b1) (b0) (b0) nil))
    (let* "-"      (do (b0) (b0) (b1) (b0) (b1) (b1) (b0) (b1) nil))
    (let* "/"      (do (b0) (b0) (b1) (b0) (b1) (b1) (b1) (b1) nil))
    (let* str-lam  (list "/" "/" "-" "l" "a" "m"))
    (let* str-lazy (list "/" "/" "-" "l" "a" "z" "y"))
    (let* opt-lam  (list "l" "a" "m" "\\n"))
    (let* opt-lazy (list "l" "a" "z" "y" "\\n"))
    (let* opt-x86  (list "x" "8" "6" "\\n"))
    (let* opt
      (cond
        ((beginswith str-lam stdin) opt-lam)
        ((beginswith str-lazy stdin) opt-lazy)
        (t opt-x86)))
    (let* 8cc-result (8cc stdin))
    (elc (append opt 8cc-result))))


(format t (compile-to-lam-lazy main))
