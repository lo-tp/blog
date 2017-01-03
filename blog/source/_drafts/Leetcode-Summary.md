---
title: Leetcode Summary
tags: Leetcode Algorithm
---

### C++
- #### `map.insert()` Couldn't Replace Existing Element
    Because element keys in a map are unique, the insertion operation checks whether each inserted element has a key equivalent to the one of an element already in the container, and if so, the element is not inserted, returning an iterator to this existing element (if the function returns a value).

- #### Conversion of Float to Int
    In C++ when casting float to int, the number is alwas floored.
    ```
    float a = 1.999;
    int b = a;
    cout << b << endl;
    // output is 1;
    ```
- #### Always Use `unsigned` if Possible
    For the range of `unsigned` is wider than the `signed` version.

- #### Avert the User of `++` in Complex Scenario
    Different compilers may behave differently 
    ```
    //Use this
    for (i++; i != nums.end(); i++)
    {
      *(si+1) =  *i + *(si);
      si++;
    }

    //Avert this
    for (i++; i != nums.end(); i++)
    {
      *(si) =  *i + *(si++);
    }
    ```
- #### Convenient Way to Initialize `array` And `vector`
  - `int a[10]={0}`
   
  - `vector <vector<char> > testData = {% raw %} {{1,2,3},{2,3,4}} {% endraw %}`
   

- #### Pass by Reference / Value
    When passing by value:
    ```
    void func(Object o);
    ```
    And then calling
    ```
    func(a);
    ```
    You will construct an Object on the stack, and will be referenced by o. This might still be a shallow copy( the internals of a and o might point to the same data ), so a might be changed. However is o is a deep copy of a, then a will not change.

    When passing by reference:
    ```
    void func(Object& o);
    ```
    And then calling
    ```
    func(a);
    ```
    You will only be giving a new way to reference a. a and o are to names for the same object. Changing inside func will make those changes visible to the caller, who know the object as a.

### Binary Search
#### Edge Cases: 
- ##### When Higherend is Very Close to Lowerend
  ```
  higherEnd=100;
  lowerEnd=99;
  ```

