(define (names)
  (amb 'mary-ann 'gabrielle 'lorna 'rosalind 'melissa))
(define (make-father last-name daughter yacht) (list last-name daughter yacht))
(define (last-name father) (car father))
(define (daughter father) (cadr father))
(define (yacht father) (caddr father))
(define (yachts-daughters)
  ; daughter yacht
  (let ((moore (make-father 'mary-ann 'lorna))
        (hood (make-father 'melissa 'gabrielle))
        (hall (make-father names 'rosalind))
        (downing (make-father names 'melissa))
        (parker (make-father names names)))
    (let ((fathers (list moore hood hall downing parker)))
      (require
        (distinct? (map daughter fathers))
        (distinct? (map yacht fathers)))
      (for-each (lambda (father) (require (not (eq? (daughter father) 
                                                    (yacht father)))))
                fathers)
      (let ((gabrielle-father (apply amb fathers)))
        (require (eq? (daughter gabrielle-father)
                      'gabrielle))
        (require (eq? (yacht gabrielle-father)
                      (daughter parker)))
        (let ((lorna-father (apply amb fathers)))
          (require (eq? (daughter lorna-father)
                        'lorna))
          (last-name lorna-father))))))
