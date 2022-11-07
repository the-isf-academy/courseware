Models
----------------

.. py:class:: Model

First, you must define your Model. Banjo provides four field types:


   - ``BooleanField`` (True, False)

   - ``IntegerField`` (1, -102)

   - ``FloatField`` (0.045, 11.5)

   - ``StringField`` ("alligator", "hazelnut")

To create a model::

   # app/models.py
   from banjo.models import Model, StringField, IntegerField, BooleanField

   class Person(Model):
      name = StringField()
      age = IntegerField()
      student = BooleanField()

      def update_age(self):
         self.age +=1
         self.save()

*To create an instance of the model in the Banjo shell:*  ``banjo --shell``

   >>> one_person = Person(name='Dragon', age=15, student=True)
   >>> one_person.save()

|

----

All Banjo models have two funcitons built it. You can override in them in the class definition.

.. py:function:: objects.to_dict()
    
   :return: a nicely formatted dictionary of the object

   *example:* 

      >>> one_person = Person(name='Dragon', age=15, student=True)
      >>> one_person.save()
      >>> one_person.to_dict()
      {'name': 'Dragon',
      'age': 15,
      'student': True}


.. py:function:: objects.from_dict()

   Takes a dictionary a nicely formats it to easily create a new object

   :return: an instance of the object

   *example:* 

      >>> another_person_dict = {
         'name':'Snail',
         'age': 88, 
         'student': False}
      >>> another_person = Person.from_dict(another_person_dict)
      >>> another_person.save()


----


Model Querying
^^^^^^^^^^^^^^^

When querying the Banjo database, it return a QuerySet. A QuerySet is a list of objects. 

.. py:function:: objects.all()

   :return: a QuerySet of all the instances of the object

   *example:* ::

      Person.objects.all()


   *To iterate, or loop, through a QuerySet:* ::

      # Prints each name of all Persons one at a time
      for person in Person.objects.all():
         print(person)




.. py:function:: objects.get()

   :return: a single of object

   *example:* ::

      Person.objects.get(id=1)


.. py:function:: objects.count()

   :return: an interger representing the number in the QuerySet

   *example:* ::

      Person.objects.count()

----

.. py:function:: objects.filter()

   :return: a QuerySet matching the filter parameters

   *example:* ::

      # Deletes the instance of Person with an id of 1
      Person.objects.filter(age=16)




.. py:function:: objects.order_by()

   :return: a QuerySet ordered in ascending order. For strings ascending order is alphabetical, for 
         integers ascending order is numerical.

   *example:* ::

      # Returns a QuerySet of Persons in alphabetical order by name
      Person.objects.order_by('name')

      # Returns a QuerySet of Persons in reverse alphabetical order by name
      Person.objects.order_by('-name')

      # Returns a QuerySet of Persons in random order by name
      Person.objects.order_by('?')



.. py:function:: objects.first()

   :return: the first object in the QuerySet

   *example:* ::

      # Returns the first Person by age
      Person.objects.first()

      # Returns the first Person with the lowest age
      Person.objects.orderby('age').first()



.. py:function:: objects.exists()

   :return: a Boolean value if the QuerySet returns any results

   *example:* ::

      # Returns a Boolean value representing if any Persons exist
      Person.objects.exists()

      # Returns a Boolean value representing if any Persons with the age of 10 exist
      Person.objects.filter(age=10).exists()




.. py:function:: objects.delete()

   Deletes all the objects in a QuerySet

   *example:* ::

      # Deletes the instance of Person with an id of 1
      Person.objects.get(id=1).delete()




.. py:function:: objects.exclude()

   :return: a QuerySet containing all objects *except* those that match the parameters

   *example:* ::

      # Returns a QuerySet of Persons without an age of 12
      Person.objects.exclude(age=12)




----



Advanced Filtering
^^^^^^^^^^^^^^^

.. py:function:: objects.filter(__startswith=)

   :return: a QuerySet containing all objects that start with a specific parameter

   *example:* ::

      # Returns a QuerySet of Persons with names that include the letter 'a'
      Person.objects.filter.(name__startswith='a')


.. py:function:: objects.filter(__endswith=)

   :return: a QuerySet containing all objects that end with a specific parameter

   *example:* ::

      # Returns a QuerySet of Persons with names that include the letter 'a'
      Person.objects.filter.(name__endswith='n')


.. py:function:: objects.filter(__contains=)

   :return: a QuerySet containing all objects that contain a specific parameter

   *example:* ::

      # Returns a QuerySet of Persons with names that start the letter 'b'
      Person.objects.filter.(name__contains='brown')


**Conditional Symbols**

.. py:function:: objects.filter(__gt=)

- ``gt``: greater than
- ``gte``: greater than or equal to
- ``lt``: less than
- ``lte``: less than or equal to

   *example:* ::

      # Returns a QuerySet of Persons with an age greater than 15
      Person.objects.filter(age__gt=15)

      # Returns a QuerySet of Persons with an age less than or equal 55
      Person.objects.filter(age__lt=55)




**Chaining Filtering**

Query functions are easily chained together to create a more specific QuerySet.

   *example:* ::

      # Returns a QuerySet of Persons with an age greater than 15 and names that start with 'a'
      Person.objects.filter(age__gt=15).filter(name__starswith="a")

      # Returns a count of Persons with an age greater than 15 and names that start with 'a'
      Person.objects.filter(age__gt=15).filter(name__starswith="a").count()

   *To iterate, or loop, through a chained QuerySet:* ::

      # Prints each name of Persons where student is True
      for person in Person.objects.filter(student=True):
         print(person.name)

----
