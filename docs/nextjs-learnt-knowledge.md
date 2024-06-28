# Learnt Knowledge when using Next.js

## e.stopPropagation()

The method `e.stopPropagation()` is used in JavaScript event handling to prevent an event from bubling up the event chain. This is particularly useful in scenarios where multiple event handlers are defined at different levels of the document tree, and you want to restrict an event to a specific handler without triggering those defined on parent elements.

### Understanding Event Propagation

In the Document Object Model (DOM), events propagate through three phases:

1. **Capturing Phase**: The event starts from the window object and goes down to the element that triggered the event, passing through each ancestor element along the way.
2. **Target Phase**: The event reaches the target element, which is the element where the event actually occurred.
3. **Bubbling Phase**: After reaching the target, the event then bubbles up from the target element to the window object, passing through each ancestor element again.

### Usage of `e.stopPropagation()`

The function `e.stopPropagation()` is used to stop further propagation of the current event in the capturing and bubbling phases. When you call this method during any stage of event flow (capturing, target, or bubbling), it stops the event from moving to the next stage.

### Practical Example

Consider a webpage with a button inside a form, and both the button and the form have click event handlers defined:

```html
<form onclick="console.log('Form clicked');">
  <button onclick="handleButtonClick(event)">Click Me</button>
</form>
```

```javascript
function handleButtonClick(e) {
  console.log('Button clicked');
  e.stopPropagation(); // Stops the event from bubbling up to the form
}
```

In this example:
- When the button is clicked, the console will log "Button clicked".
- Normally, after handling the button's click event, the event would bubble up to the form, triggering its click event and logging "Form clicked".
- However, because `e.stopPropagation()` is called in the button’s click handler, the event does not bubble up to the form, and "Form clicked" is not logged.

### Why Use `e.stopPropagation()`?

Using `e.stopPropagation()` can be crucial in complex applications where multiple event handlers might interfere with each other, leading to unexpected behaviors. It allows developers to precisely control how events are handled and ensures that events do not trigger handlers where they are not intended to. This is particularly important in component-based architectures (like React), where local component interactions might not be intended to influence the broader application state or behavior.
