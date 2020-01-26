/*
 * Copyright (C) 2009 The Guava Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.common.collect;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.CollectPreconditions.checkEntryNotNull;
import static com.google.common.collect.Maps.keyOrNull;

import com.google.common.annotations.Beta;
import com.google.common.annotations.GwtCompatible;
import com.google.errorprone.annotations.CanIgnoreReturnValue;
import com.google.j2objc.annotations.WeakOuter;
import java.util.AbstractMap;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Map;
import java.util.NavigableMap;
import java.util.SortedMap;
import java.util.Spliterator;
import java.util.TreeMap;
import java.util.function.BiConsumer;
import java.util.function.BinaryOperator;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.stream.Collector;
import java.util.stream.Collectors;
import org.checkerframework.checker.nullness.qual.Nullable;

/**
 * A {@link NavigableMap} whose contents will never change, with many other important properties
 * detailed at {@link ImmutableCollection}.
 *
 * <p><b>Warning:</b> as with any sorted collection, you are strongly advised not to use a {@link
 * Comparator} or {@link Comparable} type whose comparison behavior is <i>inconsistent with
 * equals</i>. That is, {@code a.compareTo(b)} or {@code comparator.compare(a, b)} should equal zero
 * <i>if and only if</i> {@code a.equals(b)}. If this advice is not followed, the resulting map will
 * not correctly obey its specification.
 *
 * <p>See the Guava User Guide article on <a href=
 * "https://github.com/google/guava/wiki/ImmutableCollectionsExplained"> immutable collections</a>.
 *
 * @author Jared Levy
 * @author Louis Wasserman
 * @since 2.0 (implements {@code NavigableMap} since 12.0)
 */
@GwtCompatible(serializable = true, emulated = true)
public final class ImmutableSortedMap<K, V> extends ImmutableSortedMapFauxverideShim<K, V>
    implements NavigableMap<K, V> {
  
  
  @Override
  ImmutableSet<Entry<K, V>> createEntrySet() {
    @WeakOuter
    class EntrySet extends ImmutableMapEntrySet<K, V> {
      
      @Override
      ImmutableList<Entry<K, V>> createAsList() {
        return new ImmutableAsList<Entry<K, V>>() {
          @Override
          public Entry<K, V> get(int index) {
            return new AbstractMap.SimpleImmutableEntry<>(
                keySet.asList().get(index), valueList.get(index));
          }

          @Override
          public Spliterator<Entry<K, V>> spliterator() {
            return CollectSpliterators.indexed(
                size(), ImmutableSet.SPLITERATOR_CHARACTERISTICS, this::get);
          }

          @Override
          ImmutableCollection<Entry<K, V>> delegateCollection() {
            return EntrySet.this;
          }
        };
      }

      @Override
      ImmutableMap<K, V> map() {
        return ImmutableSortedMap.this;
      }
    }
    return isEmpty() ? ImmutableSet.<Entry<K, V>>of() : new EntrySet();
  }

}
