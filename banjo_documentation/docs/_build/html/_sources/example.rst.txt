Example: Person Contact Server
----------------

This is the full code example for the Person server. 


``models.py``::

    # app/models.py
    from banjo.models import Model, StringField, IntegerField, BooleanField

    class Person(Model):
        name = StringField()
        age = IntegerField()
        student = BooleanField()

        def update_age(self):
            self.age +=1
            self.save()



``views.py``::
    
    # app/views.py
    from banjo.urls import route_get, route_post
    from .models import Person

    @route_get('all')
    def all_persons(params):
        if Person.objects.exists():
            all_persons = []

            for person in Person.objects.all():
                all_persons.append(person.to_dict())

            return {'all persons': all_persons}

        else:
            return {'error': 'no persons exists'}

    @route_get('all_students')
    def all_students(params):
        if Person.objects.filter(student=True).exists():
            all_students = []

            for person in Person.objects.filter(student=True):
                all_students.append(person.to_dict())

            return {'all students': all_students}

        else:
            return {'error': 'no persons exists'}

    @route_get('one', args={'id': int})
    def one_person(params):
        if Person.objects.filter(id=params['id']).exists():
            one_person = Person.objects.get(id=params['id'])

            return {'person': one_person.to_dict()}

        else:
            return {'error': 'no person exists'}
    
    @route_post('add_person', args={'name': str, 'age': int, 'student': bool})
    def add_person(params):
        new_person = Person.from_dict(params)
        new_person.save()

        return new_person.to_dict()



    