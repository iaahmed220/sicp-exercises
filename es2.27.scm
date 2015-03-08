(define (deep-reverse list1)
  (define (reverse-order source target)
    (if (null? source)
        target
        (reverse-order (cdr source)
                      (cons (car source)
                            target))))
  (define (reverse-elements items)
    (map (lambda (maybe-list) 
           (if (pair? maybe-list)
               (reverse-order maybe-list (list))
               maybe-list))
         items))
  (reverse-elements (reverse-order list1 (list))))

(define x (list (list 1 2) (list 3 4)))
