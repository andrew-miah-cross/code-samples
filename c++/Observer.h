//
//  Observer.hpp
//  Glyph
//
//  Created by Andrew Miah Cross on 01/11/2012.
//  Copyright (c) 2012 Andrew Miah Cross. All rights reserved.
//

#ifndef Glyph_Observer_hpp
#define Glyph_Observer_hpp

#import <vector>
using namespace std;


template <typename T>
class IObservable {
public:
    virtual bool notifyObservers()=0;
};


template <typename T>
class IObserver {
    
public:
    virtual bool notification( IObservable<T>* observable )=0;
};



template <typename T>
class Observable : public IObservable<T> {
    
public:
    Observable() {
        observers = vector<IObserver<T>*>();
    }
    
    
private:
    vector<IObserver<T>*> observers;
    
protected:
    bool notifyObservers() {
        for( int i=0 ; i<observers.size() ; i++ ) {
            IObserver<T>* o = observers[i];
            if( o->notification( this ) )
                return true;
        }
        return false;
    };
    
public:
    // Add observer.
    int addObserver( IObserver<T>* o ) {
        observers.push_back( o );
        return observers.size();
    };
    
};

#endif
