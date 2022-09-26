(load "./lambdacraft.cl")


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

(defun-lazy main (8cc elc maybe-stdin)
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
    (let* opt-lam    (list "l" "a" "m" "\\n"))
    (let* opt-lazy   (list "l" "a" "z" "y" "\\n"))
    (let* opt-x86    (list "x" "8" "6" "\\n"))
    (if-then-return (istrue maybe-stdin)
      (lambda (opt stdin)
        (do
          (<- (o1 o2 o3) (opt))
          (elc (append opt-x86 (8cc stdin))))))
    (elc (append opt-x86 (8cc maybe-stdin)))))


(format t (compile-to-lam-lazy main))
