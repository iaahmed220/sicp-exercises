; data structure
(define (=number? exp num)
  (and (number? exp) (= exp num)))
(define (not-zero? exp)
  (not (=number? exp 0)))
(define (not-number? exp)
  (not (number? exp)))
(define (variable? x) (symbol? x))
(define (same-variable? v1 v2)
  (and (variable? v1) (variable? v2) (eq? v1 v2)))
(define (intersperse element sequence)
  (if (>= 1
          (length sequence))
      sequence
      (append (list (car sequence)
                   element)
              (intersperse element
                           (cdr sequence)))))
(define (make-sum . addends)
  (let ((numbers (filter number? addends))
        (not-numbers (filter not-number? addends)))
    (cond ((eq? '() addends)
           0)
          ((equal? '(0) numbers) 
           (apply make-sum not-numbers))
          ((= 1
              (length addends))
           (car addends))
          ((> (length numbers)
              1)
           (apply make-sum
                  (append (list (reduce-left + 0 numbers))
                           not-numbers)))
          (else (intersperse '+ addends)))))
(define (sum? x)
  (and (pair? x)
       (eq? (cadr x) '+)
       (sum? (cddr x))))
(define (addend s) (car s))
(define (augend s) 
  (let ((others (cddr s)))
    (if (eq? '() others)
        0
        (cons '+ others))))
(define (make-product . factors)
  (let ((numbers (filter number? factors))
        (not-numbers (filter not-number? factors)))
    (cond ((eq? '() factors)
           1)
          ((equal? '(1) numbers) 
           (apply make-product not-numbers))
          ((any zero? numbers)
           0)
          ((= 1
              (length factors))
           (car factors))
          ((> (length numbers)
              1)
           (apply make-product
                  (append (list (reduce-left * 1 numbers))
                           not-numbers)))
          (else (intersperse '* factors)))))
  ; if one is zero everything is zero ((or (=number? m1 0) (=number? m2 0)) 0)
(define (product? x)
  (and (pair? x) (eq? (car x) '*)))
(define (multiplier p) (cadr p))
(define (multiplicand p)
  (let ((others (cddr p)))
    (if (eq? '() others)
        1
        (cons '* others))))
; deriv
(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp)
         (if (same-variable? exp var) 1 0))
        ((sum? exp)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
           (make-product (multiplier exp)
                         (deriv (multiplicand exp) var))
           (make-product (deriv (multiplier exp) var)
                         (multiplicand exp))))
        (else
          (error "unknown expression type -- DERIV" exp))))
