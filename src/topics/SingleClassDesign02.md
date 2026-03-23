# Design of a single class - Contracts

## Operations (Commands and Queries)

Clients of the class API invoke **operations**. An operation is something that changes the state (the values of any fields) of an object or returns a value or both. Directly getting or setting field values (although we have discussed why this is a bad idea), and calling methods are both implementations of operations.

- An operation that changes an object's state is a **command**. If the command doesn't return a value, then it is sometimes called a **procedure**.
- An operation that accesses, but does not change, an object's state is a **query**. Queries always return a value.

## Parameters and Arguments

Operations may have **parameters** - a list of types which form part of the operation declaration (these are the **formal parameters**). The **arguments** (technically the **actual parameters**) are the values passed by a client.

In this example the formal parameter is a `double` named discount, and the argument will be whatever discount the client wants to set.

``` Java
public class Product {

     public void setDiscount(double discount)
    {
        //implementation
    }
}
```

## Pre-conditions, Post-conditions, and Invariants

### Pre-conditions

A **pre-condition** is an expression that must be true when an operation is called. An operation might have multiple pre-conditions.
Pre-conditions might apply to the internal state of the instance, arguments passed to the operation or both.

In the example below the pre-conditions on the setDiscount operation are that argument is between 0 and the value of fullPrice.


``` Java
class Product {

    private double discount;
    private final double fullPrice;

    public Product(double fullPrice) {

        this.fullPrice = fullPrice;
    }

    public void setDiscount(double discount) {
        //check pre-conditions
        if(discount < 0d)
        {
            //throw an exception
        }
        if(discount > fullPrice)
        {
            //throw an exception
        }


        //It is safe to perform  the operation
        this.discount = discount;
    }
}
```
It is the responsibility of the client to know and check the pre-condition(s) before requesting the operation.

The pre-condition(s) must be true to perform the operation, so if the pre-condition isn't true we don't correct it or change the behavior of the operation - we fail by throwing an exception.

Pre-conditions are optional - not every operation requires pre-conditions but most do (pre-condition checks on the arguments being more common than pre-conditions on the object state).

> ⚠ Formally, we can say a pre-condition is a constraint that must be true when the operation is invoked (Rumbaugh *et al.* 2005 p. 531).

### Post-conditions

A **post-condition** is an expression that must true when an operation completes. It is the responsibility of the operation to know and check the post-condition.

For example, the `setDiscountPercent` operation may do complex calculations or processing on the requested discount, we may want to check the post-condition that the applied discount is valid after the operation completes. Again, if the post-condition isn't true, we don't correct it - we fail by throwing an exception.

``` Java
Product {

    private double discount;
    private final double fullPrice;

    public Product(double fullPrice) {

        this.fullPrice = fullPrice;
    }

    public void setDiscountPercent(int discountPercent)
    {
        //convert from a percent to a multiplier
        double discount = fullPrice * (double)discountPercent/100d;


        if(discount < 0d)
        {
            //throw an exception
        }

        if(discount > fullPrice)
        {
            //throw an exception
        }
        //it is safe to update the state of object
        this.discount = discount;
    }
}

```
> ⚠ Formally, we can say a post-condition is a constraint that must be true at the completion of the operation (Rumbaugh *et al.* 2005 p.528).

As well as updating object state, some operations return results in their return values. There may be post-conditions applied to the return value, for example a post condition that constrains the range of return values.

### Class Invariants

Pre-conditions and post-conditions are associated with a particular operation and as such they can only say that the operation can start (the pre-conditions) and has been implemented correctly (the post-conditions).

A **class invariant** is an expression that must be true after *any* operation has completed (including the operation that created and initialized the object) at the class level. It allows us to ensure that the object is always in a valid state - when it is created and then after any operations.

An invariant check ensures that all the instance variables have valid values relative to each other, usually where the definition of valid depends on more than one value.

For example, say we have a minimum price for a product that we must never sell below. If we allow clients to set price and set discounts, either operation could put a product object into an invalid state (a below minimum selling price). We write a single method that checks the class invariant(s).


``` Java

class Product {

    private final double minimumSellingPrice;
    private double discount;
    private double fullPrice;

    public Product(double fullPrice, double minimumSellingPrice)
    {
        this.fullPrice = fullPrice;
        this.minimumSellingPrice = minimumSellingPrice;
        checkInvariants();
    }

    public void setDiscount(double discount) {
        //check pre- and post-conditions
        this.discount = discount;
        checkInvariants();
    }

    public void setFullPrice(double fullPrice) {
        //check pre- and post-conditions
        this.fullPrice = fullPrice;
        checkInvariants();
    }

    public double getSellingPrice() {
        return fullPrice - discount;
    }


    private void checkInvariants()
    {
        if(minimumSellingPrice < 0d)
        {
            //throw exception
        }

        if(getSellingPrice() < minimumSellingPrice)
        {
            //throw exception
        }
    }

}
```
> ⚠ Formally, we can say an invariant is a constraint that must always be true when operations are complete (Rumbaugh *et al.* 2005 p.423).

Establishing all the class invariants is the responsibility of the constructor(s). Maintaining the invariant is the responsibility of the command operations (operations that change state). Invariants can be *temporarily* broken during the execution of an operation but must be restored before the operation completes.

## Exceptions

All exceptions in Java are a subclasses of the `Throwable` class.

The classes `Exception` and `Error` are the direct subclasses of Throwable. Java uses these two different classes to classify exceptions:

- `Errors` are used by the Java Runtime for internal errors that are not recoverable as far as your program is concerned (they are for the Java runtime to handle).
- `Exceptions` should be used for application errors which are (potentially) recoverable.

Application code can specify `Exception` in the catch statement to catch all exceptions from which recovery may be possible without catching errors from which recovery is not possible.

``` Java
try{
    //stuff
} catch(Exception ex)
{

}

```
Subclasses of `Exception` (apart from the class `RuntimeException` and its subclasses) are called **checked exceptions**.

> 🛈 RuntimeException is the superclass of all the exceptions which may be thrown for many reasons during expression evaluation, but from which recovery may still be possible (Oracle 2024, Ch 11.1)

Java requires unhandled (i.e. not caught within the method) checked exceptions to be declared as part of the method signature using the `throws` keyword.

``` Java
String readData() throws EOFException
{
   . . .
   if(something)
      throw new EOFException();
   . . .
   return s;
}
```

This tells the compiler to check that the method is being called within a try/catch block OR from another method specifying the same checked exception using the `throws` keyword.

This means that the checked exception(s) become part of the method signature (along with the types of the formal parameters and the return type) and therefore part of the design of the class.


## Contracts

The **pre-conditions**, **post-conditions**, **class invariants** and **checked exceptions** form a **contract** between the supplier class and its clients.

- The client will not call an operation on your class with invalid arguments (the **pre-conditions** must be true).
- The supplier's operation will guarantee to the client that it will leave any fields it changed in a valid state, and any return values will be in defined range (the **post-conditions** are true).
- The class state as a whole (the values of all fields) will be valid after it is created and after every operation has completed successfully (the **invariants** are true).
- If an exception is thrown by an object, then the client cannot trust the state of the object will be valid.

We now have a template for implementing constructors and operations:

Constructors set the initial state of the object
- check the pre-conditions
- set the initial state
- check the class invariants

Command Operations are any operations that change state
- check the pre-conditions
- perform the operation
- check the post-conditions
- check the class invariants

Query operations do not change state, but they still have pre-conditions (things which must be true for the query to be able to execute)
- check the pre-conditions
- perform the query

If this looks like a lot of work, it is! However, this is what it takes to write high-quality code. In practice, it is not always necessary to write full pre-condition, post-condition and class invariant checks, but as a design question you should ask yourself what is the contract supplier and client. As Java doesn't have any support for these checks in the language itself, it is up to you as the developer to ensure you are meeting the contract.

> ⚠ A note about implementing pre-condition, post-condition and invariant checks. Instead of using exceptions, Java has an `assert` statement that evaluates a Boolean expression. Assertions have to be enabled by running the Java program with the `-ea` or `--enableassertions`  flag. The idea of the `assert` is that assertion checking is enabled during program development and testing, and disabled for deployment to improve performance as the asserted expression is not evaluated.
