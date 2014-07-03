
import 'dart:html';

void main() {
  new VisitView(new Visit()).form();
}

class VisitView{
  
  Visit visit;
  
  VisitView(Visit visit){
    this.visit = visit;
  }
  
  
  void form(){
    DateInputElement dateInput = new DateInputElement();
    NumberInputElement boysInput = new NumberInputElement();
    NumberInputElement girslInput = new NumberInputElement();
    NumberInputElement menInput = new NumberInputElement();
    NumberInputElement womenInput = new NumberInputElement();
    
    dateInput.valueAsDate = visit.date;
    boysInput.valueAsNumber = visit.boys;
    girslInput.valueAsNumber = visit.girls;
    menInput.valueAsNumber = visit.men;
    womenInput.valueAsNumber = visit.women;

    Element form = querySelector("#input_visits");
    form.append(dateInput);
    form.append(boysInput);
    form.append(girslInput);
    form.append(menInput);
    form.append(womenInput);
  }
  
  void draw(){
  }
}

class Visit{
  DateTime date;
  int boys, girls, men, women;
  
  Visit(){
    date = new DateTime.now();
    boys = 0;
    girls = 0;
    men = 0;
    women = 0;
  }   
}
