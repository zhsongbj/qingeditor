;; Copyright (c) 2016-2017 zzu_softboy & Contributors
;;
;; qingeditor (www.qingeditor.org)
;; Author: zzu_softboy <zzu_softboy@163.com>
;; Github: https://www.github.com/qingeditor/qingeditor
;;
;; This file is not part of GNU Emacs.
;; License: MIT
;;
;; 测试数据结构包中的`hash-table'

(require 'ert)
(load-file (expand-file-name (concat user-emacs-directory "/tests/env-init.el")))
(require 'qingeditor-hash-table)

;;(setq ert-batch-backtrace-right-margin 1000)

(defun qingeditor/test/ds/prepare-hash-table (test-func)
  "为测试准备一个`hash-table`对象'。'"
  (let ((ht (qingeditor/hash-table/init)))
    (funcall test-func)))

(ert-deftest qingeditor/test/ds/create-hash-table-test ()
  :tags '(qingeditor/ds/hash-table/create-hash-table)
  (let ((ht (qingeditor/hash-table/init)))
    (should (object-of-class-p ht qingeditor/hash-table))))

(ert-deftest qingeditor/test/ds/hash-table-set-test ()
  :tags '(qingeditor/hash-table/set)
  "`hash-table'的`set'函数测试。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (let ((table (oref ht :table))
	   (new-table (make-hash-table)))
       ;; 普通的值
       (qingeditor/cls/set ht 'name "softboy")
       (qingeditor/cls/set ht 'age 12)
       ;; 存放一下`list'
       (qingeditor/cls/set ht 'props '(a b c))
       ;; 存放一下`hash-table'
       (qingeditor/cls/set ht 'data new-table)
       (should (equal (hash-table-count table) 4))
       (should (equal (gethash 'name table) "softboy"))
       (should (equal (gethash 'age table) 12))
       (should (equal (gethash 'props table) '(a b c)))
       (should (eq (gethash 'data table) new-table))))))

(ert-deftest qingeditor/test/ds/hash-table-get-test ()
  :tags '(qingeditor/hash-table/get)
  "`hash-table'的`get'函数测试。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (let ((table (oref ht :table))
	   (new-table (make-hash-table)))
       ;; 普通的值
       (qingeditor/cls/set ht 'name "softboy")
       (qingeditor/cls/set ht 'age 12)
       ;; 存放一下`list'
       (qingeditor/cls/set ht 'props '(a b c))
       ;; 存放一下`hash-table'
       (qingeditor/cls/set ht 'data new-table)
       (should (equal (qingeditor/cls/get ht 'name) "softboy"))
       (should (equal (qingeditor/cls/get ht 'age) 12))
       (should (equal (qingeditor/cls/get ht 'props) '(a b c)))
       (should (eq (qingeditor/cls/get ht 'data) new-table))
       (should (equal (qingeditor/cls/get ht 'not-exist "haha") "haha"))))))

(ert-deftest qingeditor/test/ds/hash-table-update-from-raw-hash-table-test ()
  :tags '(qingeditor/hash-table/update-from-raw-hash-table)
  "测试从原生的`hash-table'批量导入数据。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (let ((raw-table (make-hash-table)))
       (qingeditor/cls/set ht 'org-data "org-data")
       ;; 数据设置
       (puthash 'name "softboy" raw-table)
       (puthash 'age 12 raw-table)
       (puthash 'data '(12 2 3) raw-table)
       (qingeditor/cls/update-from-raw-hash-table ht raw-table)
       ;; 判断结果
       (should (equal (qingeditor/cls/count ht) 4))
       (should (equal (qingeditor/cls/get ht 'name) "softboy"))
       (should (equal (qingeditor/cls/get ht 'age) 12))
       (should (equal (qingeditor/cls/get ht 'data) '(12 2 3)))
       ;; 不能覆盖老数据
       (should (equal (qingeditor/cls/get ht 'org-data) "org-data"))))))

(ert-deftest qingeditor/test/ds/hash-table-update-from-hash-table-test ()
  :tags '(qingeditor/hash-table/update-from-hash-table)
  "从其他`qingeditor/hash-table'对象批量设置。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (let ((new-table (qingeditor/hash-table/init)))
       (qingeditor/cls/set new-table 'name "softboy")
       (qingeditor/cls/set new-table 'age 12)
       (qingeditor/cls/set new-table 'data '(1 2 3 4))
       ;; 导入数据
       (qingeditor/cls/update-from-hash-table ht new-table)
       (should (equal (qingeditor/cls/count ht) 3))
       (should (equal (qingeditor/cls/get ht 'name) "softboy"))
       (should (equal (qingeditor/cls/get ht 'age) 12))
       (should (equal (qingeditor/cls/get ht 'data) '(1 2 3 4)))))))

(ert-deftest qingeditor/test/ds/hash-table-count-test ()
  :tags '(qingeditor/hash-table/count)
  "测试`hash-table'的个数。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'name "softboy")
     (qingeditor/cls/set ht 'age 123)
     (qingeditor/cls/set ht 'data '(1 2 3))
     (should (equal (qingeditor/cls/count ht) 3)))))

(ert-deftest qingeditor/test/ds/hash-table-merge-from-raw-hash-tables-test ()
  :tags '(qingeditor/hash-table/merge-from-raw-hash-tables)
  "将指定的原生的`hash-table'合并到当前的`hash-table'里面来。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (let ((raw-ht1 (make-hash-table))
	   (raw-ht2 (make-hash-table))
	   (raw-ht3 (make-hash-table)))
       (puthash 'name "tom" raw-ht1)
       (puthash 'age 12 raw-ht1)
       (puthash 'data '(1 2 3) raw-ht2)
       (puthash 'version "v0.0.1" raw-ht2)
       (puthash 'name "topjs" raw-ht3)
       (puthash 'info 2 raw-ht3)
       (qingeditor/cls/merge-from-raw-hash-tables ht  raw-ht1 raw-ht2 raw-ht3)
       ;; 比较数据
       (should (equal (qingeditor/cls/count ht) 5))
       (should (equal (qingeditor/cls/get ht 'name) "topjs"))
       (should (equal (qingeditor/cls/get ht 'age) 12))
       (should (equal (qingeditor/cls/get ht 'data) '(1 2 3)))
       (should (equal (qingeditor/cls/get ht 'info) 2))
       (should (equal (qingeditor/cls/get ht 'version) "v0.0.1"))))))

(ert-deftest qingeditor/test/ds/hash-table-merge-from-hash-tables ()
  :tags '(qingeditor/hash-table/merge-from-hash-tables)
  "将指定的`hash-table'对象合并到当前的`hash-table'里面。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (let ((ht1 (qingeditor/hash-table/init))
	   (ht2 (qingeditor/hash-table/init))
	   (ht3 (qingeditor/hash-table/init)))
        (qingeditor/cls/set ht1 'name "tom")
	(qingeditor/cls/set ht1 'age 12)
	(qingeditor/cls/set ht2 'data '(1 2 3))
	(qingeditor/cls/set ht2 'version "v0.0.1")
	(qingeditor/cls/set ht3 'name "topjs")
	(qingeditor/cls/set ht3 'info 2)
	(qingeditor/cls/merge-from-hash-tables ht ht1 ht2 ht3)
	;; 比较数据
	(should (equal (qingeditor/cls/count ht) 5))
	(should (equal (qingeditor/cls/get ht 'name) "topjs"))
	(should (equal (qingeditor/cls/get ht 'age) 12))
	(should (equal (qingeditor/cls/get ht 'data) '(1 2 3)))
	(should (equal (qingeditor/cls/get ht 'info) 2))
	(should (equal (qingeditor/cls/get ht 'version) "v0.0.1"))))))

(ert-deftest qingeditor/test/ds/hash-table-remove-test ()
  :tags '(qingeditor/hash-table/remove)
  "从当前的`hash-table'里面删除指定的`key'。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'name "tom")
     (qingeditor/cls/set ht 'age 12)
     (should (equal (qingeditor/cls/count ht) 2))
     (qingeditor/cls/remove ht 'name)
     (should (equal (qingeditor/cls/count ht) 1)))))

(ert-deftest qingeditor/test/ds/hash-table-clear-test ()
  :tags '(qingeditor/hash-table/clear)
  "清空当前的`hash-table'。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'name "softboy")
     (qingeditor/cls/set ht 'age 123)
     (should (equal (qingeditor/cls/count ht) 2))
     (qingeditor/cls/clear ht)
     (should (equal (qingeditor/cls/count ht) 0)))))

(ert-deftest qingeditor/test/ds/hash-table-map-test ()
  :tags '(qingeditor/hash-table/map)
  "测试映射方法"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'name "softboy")
     (qingeditor/cls/set ht 'age 12)
     (let ((keys nil)
	   (values '())
	   (called-count 0)
	   ret)
       (setq ret (qingeditor/cls/map
		  ht (lambda (key value)
		       (push key keys)
		       (push value values)
		       (setq called-count (1+ called-count))
		       (cons key value))))
       (should (equal keys '(age name)))
       (should (equal values '(12 "softboy")))
       (should (equal ret '((age . 12) (name . "softboy"))))))))

(ert-deftest qingeditor/test/ds/hash-table-keys-test ()
  :tags '(qingeditor/hash-table/keys)
  "测试获取`hash-table'的键集合。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'name "softboy")
     (qingeditor/cls/set ht 'age 12)
     (let (keys)
       (setq keys (qingeditor/cls/keys ht))
       (should (equal keys '(age name)))))))

(ert-deftest qingeditor/test/ds/hash-table-values-test ()
  :tags '(qingditor/hash-table/hash-table-values)
  "测试获取`hash-table'的值。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
      (qingeditor/cls/set ht 'name "softboy")
      (qingeditor/cls/set ht 'age 12)
      (let (values)
	(setq values (qingeditor/cls/values ht))
	(should (equal values '(12 "softboy")))))))

(ert-deftest qingeditor/test/ds/hash-table-items-test ()
  :tags '(qingditor/hash-table/items)
  "测试获取`hash-table'的键值集合。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
      (qingeditor/cls/set ht 'name "softboy")
      (qingeditor/cls/set ht 'age 12)
      (let (items)
	(setq items (qingeditor/cls/items ht))
	(should (equal items '((age 12) (name "softboy"))))))))

(ert-deftest qingeditor/test/ds/hash-table-iterate-items-test ()
  :tags '(qingeditor/hash-table/iterate-items)
  "迭代`hash-table'的每个元素。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'name "softboy")
     (qingeditor/cls/set ht 'age 12)
     (let (keys
	   values
	   ret)
       (qingeditor/cls/iterate-items ht (push key keys))
       (qingeditor/cls/iterate-items ht (push value values))
       (setq ret (qingeditor/cls/iterate-items ht (list key value)))
       (should (equal keys '(age name)))
       (should (equal values '(12 "softboy")))
       (should (equal ret nil))))))

(ert-deftest qingeditor/test/ds/hash-table-find-test ()
  :tags '(qingeditor/hash-table/find)
  "需要回调函数返回真值得方法。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
      (qingeditor/cls/set ht 'name "softboy")
      (qingeditor/cls/set ht 'age 12)
      (let (ret)
	(setq ret (qingeditor/cls/find
		   ht (lambda (key value)
			(if (eq key 'name)
			    t))))
	(should (equal ret '(name "softboy")))
	(setq ret (qingeditor/cls/find
		   ht (lambda (key value)
			(if (eq key 'not-exist) t))))
	(should (equal ret nil))))))

(ert-deftest qingeditor/test/ds/hash-table-empty-test ()
  :tags '(qingeditor/hash-table/empty)
  "测试空值的判断。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (should (equal (qingeditor/cls/empty ht) t))
     (qingeditor/cls/set ht 'name "softboy")
     (should (equal (qingeditor/cls/empty ht) nil)))))

(ert-deftest qingeditor/test/ds/hash-table-set-from-alist-test ()
  :tags '(qingeditor/hash-table/set-from-alist)
  "测试使用`alist'设置当前的`hash-table'。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'phone 1234)
     (qingeditor/cls/set-from-alist ht '((name . "softboy") (age . 12) (name . "cntysoft")))
     (should (equal (qingeditor/cls/get ht 'name) "cntysoft"))
     (should (equal (qingeditor/cls/get ht 'age) 12))
     (should (equal (qingeditor/cls/get ht 'phone) 1234)))))

(ert-deftest qingeditor/test/ds/hash-table-set-from-plist ()
  :tags '(qingeditor/hash-table/set-from-plist)
  "测试使用`plist'设置当前的`hash-table'。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'phone 1234)
     (qingeditor/cls/set-from-plist ht '(name "xiuxiu" age 12 address "beijing"))
     (should (equal (qingeditor/cls/get ht 'name) "xiuxiu"))
     (should (equal (qingeditor/cls/get ht 'age) 12))
     (should (equal (qingeditor/cls/get ht 'address) "beijing")))))


(ert-deftest qingeditor/test/ds/hash-table-to-plist-test ()
  :tags '(qingeditor/hash-table/to-plist)
  "转换成`plist'测试。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()

     (let* ((init-plist '(name "xiuxiu" age 12 address "beijing"))
	   (plist))
       (qingeditor/cls/set-from-plist ht init-plist)
       (setq plist (qingeditor/cls/to-plist ht))
       (should (equalp (length init-plist) (length plist)))
       (should (equalp (plist-get plist 'name) (plist-get init-plist 'name)))
       (should (equalp (plist-get plist 'age) (plist-get init-plist 'age)))
       (should (equalp (plist-get plist 'address) (plist-get init-plist 'address)))))))

(ert-deftest qingeditor/test/ds/hash-table-to-alist-test ()
  :tags '(qingeditor/hash-table/set-from-alist)
  "将`hash-table'转换成`alist'的测试。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (let ((init-alist '((age . 12) (name . "cntysoft")))
	   (alist))
       (qingeditor/cls/set-from-alist ht init-alist)
       (setq alist (qingeditor/cls/to-alist ht))
       (should (equalp (length alist) (length init-alist)))
       (should (equalp (alist-get 'name alist) (alist-get 'name init-alist)))
       (should (equalp (alist-get 'age alist) (alist-get 'age init-alist)))))))

(ert-deftest qingeditor/test/ds/hash-table-has-key-test ()
  :tags '(qingeditor/hash-table/set-from-alist)
  "判断`hash-table'是否存在`key'."
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
      (qingeditor/cls/set ht 'name "softboy")
      (qingeditor/cls/set ht 'age 12)
      (should (equalp (qingeditor/cls/has-key ht 'name) t))
      (should (equalp (qingeditor/cls/has-key ht 'not-exist) nil)))))

(ert-deftest qingeditor/test/ds/hash-table-select-test ()
  :tags '(qingeditor/hash-table/select)
  "获取满足条件的`hash-table'里面的项。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'name "softboy")
     (qingeditor/cls/set ht 'age 12)
     (qingeditor/cls/set ht 'address "beijing")
     (let ((new-table))
       (setq new-table
	     (qingeditor/cls/select
	      ht (lambda (key value)
		   (or (eq key 'name) (equalp value "beijing")))))
       (should (object-of-class-p new-table qingeditor/hash-table))
       (should (equalp (qingeditor/cls/count new-table) 2))
       (should (equal (qingeditor/cls/has-key new-table 'name) t))
       (should (equal (qingeditor/cls/has-key new-table 'address) t))))))

(ert-deftest qingeditor/test/ds/hash-table-remove-item-by-test ()
  :tags '(qingeditor/hash-table/remove-item-by)
  "根据函数删除`hash-table'里面的项。"
  (qingeditor/test/ds/prepare-hash-table
   (lambda ()
     (qingeditor/cls/set ht 'name "softboy")
     (qingeditor/cls/set ht 'age 12)
     (qingeditor/cls/set ht 'address "beijing")
     (qingeditor/cls/remove-item-by
      ht (lambda (key value) (or (eq key 'address))))
     (should (equalp (qingeditor/cls/has-key ht 'address) nil)))))

(ert-deftest qingeditor/test/ds/hash-table-make-table-from-paires-test ()
  :tags '(qingeditor/hash-table/make-table-from-paires)
  "从`paires'集合初始化一个`hash-table'"
  (let (ht)
    (setq ht (qingeditor/cls/make-table-from-paires
	      ('name  "softboy") ('age  12) ('address  "beijing") ))
    (should (equalp (qingeditor/cls/count ht) 3))
    (should (equalp (qingeditor/cls/has-key ht 'name) t))
    (should (equalp (qingeditor/cls/get ht 'name) "softboy"))
    (should (equalp (qingeditor/cls/has-key ht 'age) t))
    (should (equalp (qingeditor/cls/get ht 'age) 12))
    (should (equalp (qingeditor/cls/has-key ht 'address) t))
    (should (equalp (qingeditor/cls/get ht 'address) "beijing"))))
