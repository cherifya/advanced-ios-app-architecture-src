/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import KooberKit
import RxSwift


class ObserverForSelectDropoffLocation: Observer {

  // MARK: - Properties
  weak var eventResponder: ObserverForSelectDropoffLocationEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }

  let dropoffLocationPickerState: Observable<DropoffLocationPickerViewControllerState>
  var dropoffLocationPickerStateSubscription: Disposable?
  var errorStateSubscription: Disposable?
  let disposeBag = DisposeBag()

  private var isObserving: Bool {
    if dropoffLocationPickerStateSubscription != nil
      && errorStateSubscription != nil
    {
      return true
    } else {
      return false
    }
  }

  // MARK: - Methods
  init(dropoffLocationPickerState: Observable<DropoffLocationPickerViewControllerState>) {
    self.dropoffLocationPickerState = dropoffLocationPickerState
  }

  func startObserving() {
    assert(self.eventResponder != nil)

    guard let _ = self.eventResponder else {
      return
    }

    if isObserving {
      return
    }

    subscribeToDropoffLocationPickerState()
    subscribeToErrorMessages()
  }

  func stopObserving() {
    unsubscribeFromDropoffLocationPickerState()
    unsubscribeFromErrorMessages()
  }

  func subscribeToDropoffLocationPickerState() {
    dropoffLocationPickerStateSubscription =
      dropoffLocationPickerState
        .subscribe(onNext: { [weak self] dropoffLocationPickerState in
          self?.received(newDropoffLocationPickerState: dropoffLocationPickerState)
        })
    dropoffLocationPickerStateSubscription?.disposed(by: disposeBag)
  }

  func received(newDropoffLocationPickerState dropoffLocationPickerState: DropoffLocationPickerViewControllerState) {
    eventResponder?.received(newDropoffLocationPickerState: dropoffLocationPickerState)
  }

  func unsubscribeFromDropoffLocationPickerState() {
    dropoffLocationPickerStateSubscription?.dispose()
  }

  func subscribeToErrorMessages() {
    errorStateSubscription =
      dropoffLocationPickerState
        .map { $0.errorsToPresent.first }
        .ignoreNil()
        .distinctUntilChanged()
        .subscribe(onNext: { [weak self] errorMessage in
          self?.received(newErrorMessage: errorMessage)
        })

    errorStateSubscription?.disposed(by: disposeBag)
  }

  func received(newErrorMessage errorMessage: ErrorMessage) {
    eventResponder?.received(newErrorMessage: errorMessage)
  }

  func unsubscribeFromErrorMessages() {
    errorStateSubscription?.dispose()
  }
}
