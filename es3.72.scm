; library
(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))
(define integers (integers-starting-from 1))
(define (display-line text)
  (display text)
  (newline))
(define (display-stream s number-of-elements)
  (if (> number-of-elements 0)
      (begin (display-line (stream-car s))
             (display-stream (stream-cdr s) (- number-of-elements 1)))))
(define (merge-weighted weight s1 s2)
  (cond ((stream-null? s1) s2)
        ((stream-null? s2) s1)
        (else
          (let ((s1car (stream-car s1))(s2car (stream-car s2)))
            (cond ((< (weight s1car)
                      (weight s2car))
                   (cons-stream s1car (merge-weighted weight
                                                      (stream-cdr s1)
                                                      s2)))
                  (else
                   (cons-stream s2car (merge-weighted weight
                                                      s1 
                                                      (stream-cdr s2)))))))))
(define (weighted-pairs weight s t)
  (cons-stream
    (list (stream-car s) (stream-car t))
    (merge-weighted
      weight
      (stream-map (lambda (x) (list (stream-car s) x))
                  (stream-cdr t))
      (weighted-pairs weight (stream-cdr s) (stream-cdr t)))))
; exercise
(define (weight-by-squares pair)
  (let ((i (car pair))
        (j (cadr pair)))
    (+ (expt i 2)
       (expt j 2))))
(define stream (weighted-pairs weight-by-squares integers integers))
(display-stream stream 10)
; special numbers for this exercise: can be written as sum of 2 squares
; in 3 different ways
(define (search-stream-for-special stream)
    (let ((first (stream-car stream))
          (second (stream-car (stream-cdr stream)))
          (third (stream-car (stream-cdr (stream-cdr stream)))))
      (if (and (equal? (weight-by-squares first)
                       (weight-by-squares second))
               (equal? (weight-by-squares second)
                       (weight-by-squares third)))
          (cons-stream 
            (list first second third (weight-by-squares first))
            (search-stream-for-special (stream-cdr stream)))
          (search-stream-for-special (stream-cdr stream)))))
(display-line "special numbers stream")
(display-stream (search-stream-for-special stream) 6)
