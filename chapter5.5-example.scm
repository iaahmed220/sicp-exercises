(load "chapter5.5.scm")
(compile-and-go
  '(define (factorial n)
     (if (= n 1)
       1
       (* (factorial (- n 1)) n))))
