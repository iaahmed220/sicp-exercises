(define (accumulate proc initial sequence)
  (if (null? sequence)
      initial
      (proc (car sequence)
            (accumulate proc initial (cdr sequence)))))
(define (map proc tree)
  (cond ((null? tree) (list))
        ((not (pair? tree)) (list tree))
        (else (append (map proc (car tree))
                      (map proc (cdr tree))))))
(define (count-leaves t)
  (accumulate (lambda (element total) (+ 1 total))
              0
              (map (lambda (leaf) leaf)
                   t)))
